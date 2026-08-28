#!/usr/bin/env bash
# bench/run-one.sh — run ONE benchmark combo (task x arm x run) against an isolated workspace,
# then evaluate the frozen metric and append exactly one row to $GM_BENCH_ROOT/results.tsv.
#
# Usage: bash bench/run-one.sh <task_id> <arm> <run#> [parent_run]
#   task_id  ^(perf|bug|test|feat|sec|refac)-[0-9]{2}$
#   arm      plain | godmode
#   run#     positive integer
#
# All writes (logs/, results.tsv, results.lock) go under $GM_BENCH_ROOT (default <repo>/bench);
# tasks live at $GM_BENCH_ROOT/tasks/<task_id>. Only README.md, metric.sh, starter/ are copied
# into the workspace — never solution/, SOLUTION.md, expected_effort, VERIFICATION.tsv, INDEX.md.
# Exits 0 after recording a row (safe under parallel xargs). Exit 2 = usage error, no row.
# Exit 3 = infra failure before a row could be recorded.

set -u

die_usage() {
  echo 'usage: bash bench/run-one.sh <task_id> <arm> <run#> [parent_run]' >&2
  echo '       task_id ^(perf|bug|test|feat|sec|refac)-[0-9]{2}$ ; arm plain|godmode ; run# positive int' >&2
  echo "run-one: $*" >&2
  exit 2
}
die_infra() { echo "run-one: infra: $*" >&2; exit 3; }

# --- Roots (this script lives at <repo>/bench/run-one.sh) ---
ROOT=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P) || die_infra "cannot resolve repo root"
GM_BENCH_ROOT=${GM_BENCH_ROOT:-$ROOT/bench}

# --- Validate args and task dir (exit 2 BEFORE any row) ---
case $# in 3|4) ;; *) die_usage "expected 3 or 4 args, got $#";; esac
task_id=$1 arm=$2 run=$3 parent_run=${4:-}
[[ "$task_id" =~ ^(perf|bug|test|feat|sec|refac)-[0-9]{2}$ ]] || die_usage "bad task_id '$task_id'"
case "$arm" in plain|godmode) ;; *) die_usage "bad arm '$arm' (want plain|godmode)";; esac
[[ "$run" =~ ^[1-9][0-9]*$ ]] || die_usage "bad run# '$run'"

TASK_DIR=$GM_BENCH_ROOT/tasks/$task_id
[ -f "$TASK_DIR/README.md" ] || die_usage "missing $TASK_DIR/README.md"
[ -f "$TASK_DIR/metric.sh" ] || die_usage "missing $TASK_DIR/metric.sh"
[ -d "$TASK_DIR/starter" ]   || die_usage "missing $TASK_DIR/starter/"

# --- Isolated workspace under ${TMPDIR:-/tmp}/gm-farm/, always cleaned up ---
FARM_TMP=${TMPDIR:-/tmp}/gm-farm
mkdir -p -- "$FARM_TMP" || die_infra "mkdir $FARM_TMP failed"
WS=$(mktemp -d "$FARM_TMP/${task_id}_${arm}_r${run}.$$.XXXXXX") || die_infra "mktemp failed"
trap 'rm -rf "$WS"' EXIT

cp -- "$TASK_DIR/README.md" "$TASK_DIR/metric.sh" "$WS/" || die_infra "copy of task files failed"
cp -R -- "$TASK_DIR/starter" "$WS/" || die_infra "copy of starter/ failed"

mkdir -p -- "$GM_BENCH_ROOT/logs" || die_infra "mkdir logs failed"
LOG=$GM_BENCH_ROOT/logs/${task_id}_${arm}_r${run}_$(date -u +%s).log

# metric.sh is immutable during runs: checksum before and after the agent.
sha_before=$(sha256sum -- "$WS/metric.sh" 2>/dev/null | awk '{print $1}')
[ -n "$sha_before" ] || die_infra "sha256sum of metric.sh failed"

# --- Env hygiene for the child pi: strip PI_*/FLEET_*/GODMODE_* exports; TZ=UTC; HOME and PATH kept ---
while IFS= read -r v; do unset "$v" 2>/dev/null || true; done \
  < <(env | sed -E 's/=.*//' | grep -E '^(PI_|FLEET_|GODMODE_)' || true)
export TZ=UTC

NAME=${task_id}_${arm}_r${run}
PROMPT="Make 'bash metric.sh' exit 0. Do not modify metric.sh."

# Model lock: BOTH arms must run the identical model (GOAL3 M3 rule 4 core).
# glm-5.3 per owner dispatch 2026-08-28 (glm-5 pin was the time-boxed quota-wall
# workaround; window reset probed 3.6s, 0 rows recorded at switch — ledgered iter 2).
MODEL=zai/glm-5.3

notes=''
add_note() { notes=${notes:+$notes;}$1; }
add_note "model:$MODEL"   # audit trail: frozen TSV schema has no model column

RESULTS=$GM_BENCH_ROOT/results.tsv
LOCKF=$GM_BENCH_ROOT/results.lock

# Append one row (creating header if absent) under an exclusive lock on fd 9.
# Requires start_ts/end_ts/start_epoch/end_epoch already set. $1=exit_code $2=metric_pass.
append_row() {
  notes=${notes//$'\t'/ }; notes=${notes//$'\n'/ }; notes=${notes//$'\r'/ }
  {
    flock -x 9
    [ -f "$RESULTS" ] || printf 'task_id\tarm\trun#\tparent_run\tstart_ts\tend_ts\texit_code\tmetric_pass\tduration_s\tnotes\n' >> "$RESULTS"
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
      "$task_id" "$arm" "$run" "$parent_run" "$start_ts" "$end_ts" "$1" "$2" \
      "$((end_epoch - start_epoch))" "$notes" >> "$RESULTS"
  } 9>> "$LOCKF"
}

# --- Agent phase; stamps bracket ONLY the agent run (metric eval excluded from duration_s) ---
start_ts=$(date -u +%Y-%m-%dT%H:%M:%SZ) start_epoch=$(date +%s)

if ! command -v pi >/dev/null 2>&1; then
  add_note 'infra:pi_not_found'
  end_ts=$start_ts end_epoch=$start_epoch
  append_row -1 0 || die_infra "row append failed"
  exit 0
fi

if [ "$arm" = godmode ]; then
  # godmode arm: repo skills via explicit --skill; -ns stays on BOTH arms so user-level
  # pi skills never auto-load.
  (
    cd -- "$WS" || exit 125
    exec timeout "${GM_RUN_TIMEOUT:-600}" pi -p -ne -nc -ns --mode text --no-session \
      --provider zai --model "$MODEL" --skill "$ROOT/skills" -n "$NAME" "$PROMPT"
  ) >> "$LOG" 2>&1
else
  (
    cd -- "$WS" || exit 125
    exec timeout "${GM_RUN_TIMEOUT:-600}" pi -p -ne -nc -ns --mode text --no-session \
      --provider zai --model "$MODEL" -n "$NAME" "$PROMPT"
  ) >> "$LOG" 2>&1
fi
rc=$?
end_ts=$(date -u +%Y-%m-%dT%H:%M:%SZ) end_epoch=$(date +%s)

[ "$rc" -eq 124 ] && add_note timeout

# --- Evaluate: tamper check first; only a pristine metric.sh is executed ---
sha_after=$(sha256sum -- "$WS/metric.sh" 2>/dev/null | awk '{print $1}')
[ -n "$sha_after" ] || sha_after=missing
if [ "$sha_before" != "$sha_after" ]; then
  metric_pass=0
  add_note "metric_tampered:${sha_before:0:8}!=${sha_after:0:8}"
else
  ( cd -- "$WS" && exec timeout 60 bash metric.sh ) >> "$LOG" 2>&1
  mrc=$?
  if [ "$mrc" -eq 0 ]; then metric_pass=1; else metric_pass=0; fi
fi

# --- Scans over the agent log ---
if grep -Fq -e 'bench/tasks' -e '/solution' -e "$ROOT" -- "$LOG"; then add_note LEAK_SCAN_HIT; fi
if grep -qiE '(^|[^0-9])429([^0-9]|$)|rate.?limit|quota[ _-]?exceed' -- "$LOG"; then add_note 429_hit; fi

append_row "$rc" "$metric_pass" || die_infra "row append failed"
exit 0
