#!/usr/bin/env bash
# demo/render.sh — render the godmode demo tapes to demo/<stem>.gif with vhs.
#
# Usage:
#   bash demo/render.sh [--check] [stem ...]
#     --check    verify deps/tapes/targets/banned patterns; never renders
#     stem ...   render only these stems (default: all three)
#
# Each render is a REAL pi session (model pinned inside the tape) and costs
# provider quota — a failed render stops the run; re-render just that stem.

set -euo pipefail

ALL_STEMS="skill-routing optimize-loop goal-bridge"
RENDER_TIMEOUT=900           # seconds per tape
WARN_BYTES=$((2560 * 1024))  # 2.5 MB soft budget per gif
FAIL_BYTES=$((5120 * 1024))  # 5 MB hard budget per gif

die()  { echo "FAIL: $*" >&2; exit 1; }
warn() { echo "WARN: $*" >&2; }

# --- Always run from the repo root (this script lives at demo/render.sh) ---
cd "$(dirname "$0")/.." || die "cannot resolve repo root from $0"
ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" \
  || die "$(pwd) is not a git repo — run from the godmode checkout"
cd "$ROOT"

CHECK=0
if [ "${1:-}" = "--check" ]; then CHECK=1; shift; fi
STEMS="${*:-$ALL_STEMS}"
for s in $STEMS; do
  case " $ALL_STEMS " in *" $s "*) ;; *) die "unknown stem '$s' (known: $ALL_STEMS)";; esac
done

# --- --check: validate the environment without rendering -------------------
if [ "$CHECK" = 1 ]; then
  echo "== dependencies =="
  for tool in vhs ttyd ffmpeg; do
    command -v "$tool" >/dev/null 2>&1 || die "dependency '$tool' not on PATH"
    case "$tool" in
      ffmpeg) ver="$("$tool" -version  2>&1 | head -n 1)" ;;
      *)      ver="$("$tool" --version 2>&1 | head -n 1)" ;;
    esac
    echo "  [ok] $tool: $ver"
  done

  echo "== tapes =="
  for s in $ALL_STEMS; do
    [ -f "demo/tapes/$s.tape" ] || die "missing tape demo/tapes/$s.tape"
    echo "  [ok] demo/tapes/$s.tape"
  done

  echo "== targets =="
  for f in demo/targets/optimize/slow_fib.py \
           demo/targets/optimize/test_slow_fib.py \
           demo/targets/optimize/metric.sh \
           demo/targets/goal-bridge/counter.py \
           demo/targets/goal-bridge/test_counter.py; do
    [ -f "$f" ] || die "missing target file $f"
    echo "  [ok] $f"
  done

  echo "== banned patterns (local paths / wrong models / secrets / gh / env|history) =="
  BANNED=(
    '/home/arbaz'
    'glm-5\.3-flash'
    'glm-5\.2-highspeed'
    'zai\.key'
    'auth\.json'
    'gh pr'
    'gh issue'
    'gh api'
    '(^|[^a-z])env([^a-z]|$)'
    '(^|[^a-z])history([^a-z]|$)'
  )
  for tape in demo/tapes/*.tape; do
    [ -f "$tape" ] || continue
    for pat in "${BANNED[@]}"; do
      hit="$(grep -nE -- "$pat" "$tape" || true)"
      [ -z "$hit" ] || { echo "FAIL: banned pattern '$pat' in $tape:" >&2; echo "$hit" >&2; exit 1; }
    done
  done
  echo "  [ok] no banned patterns in demo/tapes/*.tape"
  echo "CHECK PASSED"
  exit 0
fi

# --- render mode: one real pi session per stem ------------------------------
command -v vhs >/dev/null 2>&1 || die "vhs not on PATH (run: bash demo/render.sh --check)"

RESULTS=""
ANY_FAIL=0
for stem in $STEMS; do
  tape="demo/tapes/$stem.tape"; gif="demo/$stem.gif"
  [ -f "$tape" ] || die "missing tape $tape (run: bash demo/render.sh --check)"
  echo "==> [$stem] real pi session, timeout ${RENDER_TIMEOUT}s ..."
  if ! timeout "$RENDER_TIMEOUT" vhs "$tape"; then
    die "render of '$stem' failed — each retry is a real pi session and costs quota. Inspect $tape, fix it, then re-run: bash demo/render.sh $stem"
  fi
  [ -f "$gif" ] || die "vhs exited 0 but $gif was not written ('$stem')"
  bytes="$(wc -c < "$gif" | tr -d '[:space:]')"
  status="ok"
  if [ "$bytes" -gt "$FAIL_BYTES" ]; then
    status="FAIL(>5MB)"; ANY_FAIL=1
  elif [ "$bytes" -gt "$WARN_BYTES" ]; then
    status="WARN(>2.5MB)"
    warn "$gif is ${bytes} bytes — over the 2.5MB soft budget; consider trimming the tape"
  fi
  RESULTS+="$stem|$gif|$bytes|$status"$'\n'
done

echo "== render summary =="
printf '%-13s | %-22s | %-9s | %s\n' "stem" "gif" "bytes" "status"
printf '%53s\n' '' | tr ' ' '-'
while IFS='|' read -r s g b st; do
  [ -n "$s" ] || continue
  printf '%-13s | %-22s | %-9s | %s\n' "$s" "$g" "$b" "$st"
done <<< "$RESULTS"

[ "$ANY_FAIL" = 0 ] || die "one or more gifs exceeded the 5MB hard limit"
echo "DONE: rendered ${STEMS}"
