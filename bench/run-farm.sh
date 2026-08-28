#!/usr/bin/env bash
# bench/run-farm.sh — M3-B1 farm driver: drain the benchmark combo queue in parallel lanes.
#
# A combo is a (task_id, arm, run#, parent_run) tuple; scored combos have an empty
# parent_run, verify-wave combos carry '<task_id>:godmode:<scored run#>'. Execution and
# row recording belong to run-one.sh (one row per combo, durable in results.tsv);
# this script only schedules, dispatches (chunked xargs), lane-adapts on rate-limit
# evidence in logs/, and checkpoints on interrupt. Re-running skips keys already in
# results.tsv, so an interrupted batch resumes without duplicates.
#
# Usage:
#   bash bench/run-farm.sh [--batch N] [--tasks a,b,...] [--lanes K]
#                          [--runs-per-combo K] [--verify-wave] [--dry-run]
#
# Env:
#   GM_BENCH_ROOT  bench dir holding results.tsv, logs/, tasks/ and (optionally, for
#                  test stubs) run-one.sh; fallback runner is <repo>/bench/run-one.sh.
#
# Exit codes: 0 ok (or dry-run) · 2 usage/validation error (before any dispatch) ·
# 130 interrupted after checkpoint.
set -u  # no -e/-o pipefail on purpose: xargs chunk pipelines and `grep -c` legitimately
        # return nonzero while the farm must keep draining the queue

LC_ALL=C
export LC_ALL

# --- Roots (this script lives at <repo>/bench/run-farm.sh) ---
SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P) || exit 1
ROOT=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd -P) || exit 1
BENCH_ROOT=${GM_BENCH_ROOT:-$ROOT/bench}
TASKS_DIR=$BENCH_ROOT/tasks
RESULTS=$BENCH_ROOT/results.tsv
LOGS_DIR=$BENCH_ROOT/logs
RUNNER=$BENCH_ROOT/run-one.sh
[ -e "$RUNNER" ] || RUNNER=$ROOT/bench/run-one.sh

TASK_RE='^(perf|bug|test|feat|sec|refac)-[0-9]{2}$'

usage() {
  cat <<'EOF'
usage: bash bench/run-farm.sh [options]

  --batch N           dispatch at most N combos this invocation (default: all)
  --tasks a,b,...     restrict to these task ids (validated, exit 2 if invalid;
                      default: all task dirs with README.md + metric.sh + starter/)
  --lanes K           parallel lanes per chunk (default 4)
  --runs-per-combo K  scored runs per (task, arm) (default 1)
  --verify-wave       add 2 godmode verify runs per done godmode scored row with
                      metric_pass=1 (parent_run '<task_id>:godmode:<scored run#>')
  --dry-run           print planned combos one per line ('task arm run [parent]'),
                      dispatch nothing, exit 0

Env: GM_BENCH_ROOT overrides the bench dir (results.tsv, logs/, tasks/, run-one.sh).
EOF
}

die2()  { echo "run-farm: ERROR: $*" >&2; exit 2; }
warn()  { echo "run-farm: WARN: $*" >&2; }
is_uint() { case $1 in ''|*[!0-9]*) return 1 ;; esac; return 0; }

# --- Options ---
batch=999999 lanes=4 runs_per_combo=1 verify_wave=0 dry_run=0 tasks_filter=
while [ $# -gt 0 ]; do
  arg=$1 val=
  case $arg in
    --batch|--lanes|--runs-per-combo|--tasks)
      [ $# -ge 2 ] || die2 "$arg requires a value"
      val=$2; shift 2 ;;
    --batch=*|--lanes=*|--runs-per-combo=*|--tasks=*)
      val=${arg#*=}; shift ;;
    --verify-wave) verify_wave=1; shift; continue ;;
    --dry-run)     dry_run=1;     shift; continue ;;
    -h|--help)     usage; exit 0 ;;
    *)             die2 "unknown argument: $arg (see --help)" ;;
  esac
  case ${arg%%=*} in
    --batch)          batch=$val ;;
    --lanes)          lanes=$val ;;
    --runs-per-combo) runs_per_combo=$val ;;
    --tasks)          tasks_filter=$val ;;
  esac
done
for spec in "batch=$batch" "lanes=$lanes" "runs-per-combo=$runs_per_combo"; do
  v=${spec#*=}
  { is_uint "$v" && [ "$v" -ge 1 ]; } || die2 "--${spec%%=*} must be a positive integer (got '$v')"
done

# --- Task list: default = valid dirs on disk; --tasks ids validated BEFORE dispatch ---
task_ok() {
  [ -f "$TASKS_DIR/$1/README.md" ] && [ -f "$TASKS_DIR/$1/metric.sh" ] && [ -d "$TASKS_DIR/$1/starter" ]
}

shopt -s nullglob
discovered=()
for d in "$TASKS_DIR"/*/; do
  id=${d%/}; id=${id##*/}
  [[ $id =~ $TASK_RE ]] || continue
  task_ok "$id" || continue
  discovered+=("$id")
done
shopt -u nullglob

TASKS=()
if [ -n "$tasks_filter" ]; then
  case $tasks_filter in
    ,*|*,|*,,* ) die2 "--tasks: empty id in list '$tasks_filter'" ;;
  esac
  IFS=',' read -r -a wanted <<<"$tasks_filter"
  for id in "${wanted[@]}"; do
    [[ $id =~ $TASK_RE ]] || die2 "--tasks: invalid task id '$id' (must match $TASK_RE)"
    task_ok "$id" || die2 "--tasks: '$id' lacks README.md + metric.sh + starter/ under $TASKS_DIR"
    dup=0
    for t in ${TASKS[@]+"${TASKS[@]}"}; do [ "$t" = "$id" ] && dup=1; done
    [ "$dup" -eq 0 ] && TASKS+=("$id")
  done
  [ ${#TASKS[@]} -gt 0 ] && mapfile -t TASKS < <(printf '%s\n' "${TASKS[@]}" | sort)
else
  for id in ${discovered[@]+"${discovered[@]}"}; do TASKS+=("$id"); done
fi

# --- Done-set: resume keys parsed from results.tsv (key = task|arm|run#|parent_run) ---
# Rows are parsed via awk: bash `read` collapses adjacent IFS-whitespace tabs, which
# would corrupt rows with empty parent_run/notes fields; awk -F'\t' preserves them.
declare -A DONE=() MAXRUN=() PASS_SCORED=() VCOUNT=()
if [ -f "$RESULTS" ]; then
  while IFS='|' read -r tid arm run parent mpass; do
    DONE["$tid|$arm|$run|$parent"]=1
    [ "${MAXRUN[$tid|$arm]:-0}" -lt "$run" ] && MAXRUN[$tid|$arm]=$run
    if [ -n "$parent" ]; then
      VCOUNT["$tid|$parent"]=$(( ${VCOUNT[$tid|$parent]:-0} + 1 ))
    elif [ "$arm" = godmode ] && [ "$mpass" = 1 ] && [ "$run" -le "$runs_per_combo" ]; then
      PASS_SCORED["$tid|$run"]=1
    fi
  done < <(awk -F'\t' '
    $1 == "task_id" && $2 == "arm" { next }
    NF != 10 {
      printf "run-farm: WARN: results.tsv:%d: malformed line (%d fields, want 10); skipped\n", NR, NF > "/dev/stderr"
      next
    }
    $1 !~ /^(perf|bug|test|feat|sec|refac)-[0-9]{2}$/ || ($2 != "plain" && $2 != "godmode") || $3 !~ /^[0-9]+$/ {
      printf "run-farm: WARN: results.tsv:%d: malformed key fields (task_id/arm/run#); skipped\n", NR > "/dev/stderr"
      next
    }
    { print $1 "|" $2 "|" $3 "|" $4 "|" $8 }
  ' "$RESULTS")
fi

# --- Queue build (deterministic): task asc, plain then godmode, run# asc ---
QUEUE=()
for tid in ${TASKS[@]+"${TASKS[@]}"}; do
  for arm in plain godmode; do
    for ((r = 1; r <= runs_per_combo; r++)); do
      [ -n "${DONE[$tid|$arm|$r|]+x}" ] && continue
      QUEUE+=("$tid|$arm|$r|")
    done
  done
done

# Verify wave: 2 godmode runs per done godmode scored row with metric_pass==1,
# run# = next available for that (task, godmode); idempotent via done-parent counts.
if [ "$verify_wave" -eq 1 ]; then
  declare -A ALLOC=()
  for tid in ${TASKS[@]+"${TASKS[@]}"}; do
    base=${MAXRUN[$tid|godmode]:-0}
    [ "$base" -lt "$runs_per_combo" ] && base=$runs_per_combo
    ALLOC[$tid|godmode]=$base
    for ((s = 1; s <= runs_per_combo; s++)); do
      [ -n "${PASS_SCORED[$tid|$s]+x}" ] || continue
      parent="$tid:godmode:$s"
      need=$(( 2 - ${VCOUNT[$tid|$parent]:-0} ))
      for ((i = 0; i < need; i++)); do
        ALLOC[$tid|godmode]=$(( ${ALLOC[$tid|godmode]} + 1 ))
        nr=${ALLOC[$tid|godmode]}
        [ -n "${DONE[$tid|godmode|$nr|$parent]+x}" ] && continue
        QUEUE+=("$tid|godmode|$nr|$parent")
      done
    done
  done
fi

planned=${#QUEUE[@]}
if [ "$batch" -lt "$planned" ]; then
  QUEUE=("${QUEUE[@]:0:$batch}")
  planned=$batch
fi

# --- Dry-run: plan only ---
if [ "$dry_run" -eq 1 ]; then
  for e in ${QUEUE[@]+"${QUEUE[@]}"}; do
    IFS='|' read -r t a r p <<<"$e"
    if [ -n "$p" ]; then printf '%s %s %s %s\n' "$t" "$a" "$r" "$p"
    else printf '%s %s %s\n' "$t" "$a" "$r"; fi
  done
  exit 0
fi

[ "$planned" -gt 0 ] || { echo "FARM: nothing to do (0 combos planned)"; exit 0; }
[ -e "$RUNNER" ] || die2 "runner not found: $RUNNER"
mkdir -p -- "$LOGS_DIR" || die2 "cannot create $LOGS_DIR"

TMPD=$(mktemp -d) || die2 "mktemp failed"
trap 'rm -rf "$TMPD"' EXIT
MARKER=$TMPD/batch_start; : >"$MARKER"        # lane-adapt scans logs newer than this
ERRFILE=$TMPD/infra_errors; : >"$ERRFILE"
export GM_RUNNER="$RUNNER" GM_ERRFILE="$ERRFILE"

# Checkpoint safety: stop dispatching, let the in-flight chunk finish, exit 130.
interrupted=0
on_signal() {
  interrupted=1
  echo "run-farm: interrupt received; finishing in-flight chunk before checkpoint" >&2
}
trap on_signal INT TERM

# --- Chunked dispatch: up to $lanes combos per xargs -P $lanes, then lane-adapt ---
idx=0
prev_hits=0
while [ "$idx" -lt "$planned" ]; do
  [ "$interrupted" -eq 0 ] || break
  n=$lanes
  [ "$n" -gt $((planned - idx)) ] && n=$((planned - idx))
  chunk=("${QUEUE[@]:$idx:$n}")
  idx=$((idx + n))

  # One line per combo: 'task arm run [parent]' -> run-one.sh <task> <arm> <run#> [parent]
  lines=()
  for e in "${chunk[@]}"; do
    IFS='|' read -r t a r p <<<"$e"
    if [ -n "$p" ]; then lines+=("$t $a $r $p"); else lines+=("$t $a $r"); fi
  done
  printf '%s\n' "${lines[@]}" \
    | xargs -r -P "$lanes" -L 1 bash -c '
        if [ -x "$GM_RUNNER" ]; then "$GM_RUNNER" "$@"; else bash "$GM_RUNNER" "$@"; fi
        rc=$?
        if [ "$rc" -ne 0 ]; then
          echo "run-farm: WARN: infra error rc=$rc combo: $*" >&2
          printf "%s\n" "$*" >>"$GM_ERRFILE"
        fi
        exit 0  # error counted above; never abort the lane mid-chunk
      ' _ >/dev/null

  # Lane-adapt: 429/rate-limit/quota hits in logs newer than batch start, per chunk.
  hits=$(find "$LOGS_DIR" -type f -newer "$MARKER" \
          -exec grep -hicE -- '429|rate[- ]?limit|quota' {} + 2>/dev/null \
          | awk '{s+=$1} END{print s+0}')
  chunk_hits=$((hits - prev_hits))
  prev_hits=$hits
  if [ "$lanes" -gt 2 ] && [ "$chunk_hits" -ge 3 ]; then
    echo "LANES_DROP: $chunk_hits rate-limit/quota hits in chunk; lanes $lanes->2 for this invocation"
    lanes=2
    sleep 30  # the single pause allowed per drop; never stall longer on 429s
  fi
  echo "FARM: progress $idx/$planned, infra_errors=$(wc -l <"$ERRFILE" | tr -d '[:space:]'), lanes=$lanes"
done

# --- Summary (recount durable rows; only run-one writes results.tsv) ---
count_done() {
  local -A seen=()
  local t a r p e c=0
  [ -f "$RESULTS" ] || { echo 0; return; }
  while IFS='|' read -r t a r p; do
    seen["$t|$a|$r|$p"]=1
  done < <(awk -F'\t' '$1 != "task_id" || $2 != "arm" { print $1 "|" $2 "|" $3 "|" $4 }' "$RESULTS")
  for e in ${QUEUE[@]+"${QUEUE[@]}"}; do
    [ -n "${seen[$e]+x}" ] && c=$((c + 1))
  done
  echo "$c"
}

done_n=$(count_done)
infra=$(wc -l <"$ERRFILE" | tr -d '[:space:]')
if [ "$interrupted" -eq 1 ]; then
  echo "CHECKPOINT: $done_n/$planned done; completed combos are durable in $RESULTS — re-run to resume"
  exit 130
fi
echo "FARM: complete $done_n/$planned done, infra_errors=$infra, lanes=$lanes"
exit 0
