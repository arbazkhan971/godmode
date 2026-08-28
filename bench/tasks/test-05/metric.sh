#!/usr/bin/env bash
# metric test-05: agent smoke suite must pass pristine main.sh and fail on 3 seeded mutants. Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout

CLI=main.sh
TESTS=starter/tests

[ -f "starter/$CLI" ] || die "missing starter/$CLI"
[ -d "$TESTS" ] || die "no tests yet: write starter/tests/run_tests.sh"
[ -f "$TESTS/run_tests.sh" ] || die "missing $TESTS/run_tests.sh"

run_case(){  # $1=variant label; cli source on stdin; returns the suite's exit status
  local case_dir="$tmp/case-$1"
  mkdir -p "$case_dir/tests"
  cat > "$case_dir/$CLI"
  cp -r "$TESTS"/. "$case_dir/tests/"
  ( cd "$case_dir" && "$TO" 15 bash tests/run_tests.sh ) >/dev/null 2>&1
}

# Variant: pristine implementation -> the suite must pass.
run_case pristine <<'IMPL'
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
IMPL
rc=$?; [ "$rc" -eq 0 ] || die "suite fails on the pristine implementation (rc=$rc) - fix the tests, not the impl"

# Mutant 1: extract unpacks members under prefixed names.
run_case m_extract_name <<'IMPL'
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
    tar -xf "$archive" -C "$dest" --transform 's,^,out_,' || exit 1
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
IMPL
rc=$?; [ "$rc" -ne 0 ] || die "mutant m_extract_name survived - extract member naming is untested"

# Mutant 2: list silently drops the first member.
run_case m_list_missing <<'IMPL'
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
    tar -tf "$archive" | tail -n +2
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
IMPL
rc=$?; [ "$rc" -ne 0 ] || die "mutant m_list_missing survived - list completeness is untested"

# Mutant 3: an unknown command exits 0 instead of 2.
run_case m_unknown_exit <<'IMPL'
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
    exit 0
    ;;
esac
exit 0
IMPL
rc=$?; [ "$rc" -ne 0 ] || die "mutant m_unknown_exit survived - usage exit codes are untested"

echo "METRIC: PASS test-05"
exit 0
