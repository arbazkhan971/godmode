#!/usr/bin/env bash
# metric bug-05: main.sh must back up every manifest-named file exactly as named, spaces included (file and stdin manifests). Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout

[ -f starter/main.sh ] || die "missing starter/main.sh"

# After a run, the vault must hold exactly $4 files (newline-safe NUL listing),
# each byte-identical to its staging copy.
vault_check(){ # $1=case-label $2=staging $3=vault $4=count  rest=names
  local label=$1 staging=$2 vault=$3 want=$4 name n=0 f
  shift 4
  while IFS= read -r -d '' f; do n=$((n+1)); done < <("$TO" 5 find "$vault" -maxdepth 1 -type f -print0)
  [ "$n" -eq "$want" ] || die "$label: vault holds $n file(s) after run, want $want"
  for name in "$@"; do
    "$TO" 5 cmp -s "$staging/$name" "$vault/$name" || die "$label: $name missing or differs in vault"
  done
}

# Case 1 (argv): three staged files; the middle manifest name contains a space.
mkdir -p "$tmp/src1"
printf 'plain payload\n' > "$tmp/src1/plain.txt"
printf 'quarterly summary body\n' > "$tmp/src1/final report.txt"
printf 'id,name\n1,ada\n2,bob\n' > "$tmp/src1/data.csv"
cat > "$tmp/c1.list" <<'EOF'
plain.txt
final report.txt
data.csv
EOF
cat > "$tmp/c1.exp" <<'EOF'
backed up: plain.txt
backed up: final report.txt
backed up: data.csv
total: 3 file(s)
EOF
"$TO" 10 bash starter/main.sh "$tmp/c1.list" "$tmp/src1" "$tmp/vault1" > "$tmp/c1.out" 2> "$tmp/c1.err" || die "case1: exit $?, want 0"
if ! diff -u "$tmp/c1.exp" "$tmp/c1.out"; then die "case1: stdout mismatch (3-file manifest)"; fi
vault_check case1 "$tmp/src1" "$tmp/vault1" 3 plain.txt "final report.txt" data.csv

# Case 2 (argv): every name contains spaces; one contains two spaces.
mkdir -p "$tmp/src2"
printf 'spend,category\n1200,travel\n800,tools\n' > "$tmp/src2/budget q3 v2.txt"
printf 'img_0001.jpg,img_0002.jpg\n' > "$tmp/src2/trip photos day 1.txt"
cat > "$tmp/c2.list" <<'EOF'
budget q3 v2.txt
trip photos day 1.txt
EOF
cat > "$tmp/c2.exp" <<'EOF'
backed up: budget q3 v2.txt
backed up: trip photos day 1.txt
total: 2 file(s)
EOF
"$TO" 10 bash starter/main.sh "$tmp/c2.list" "$tmp/src2" "$tmp/vault2" > "$tmp/c2.out" 2> "$tmp/c2.err" || die "case2: exit $?, want 0"
if ! diff -u "$tmp/c2.exp" "$tmp/c2.out"; then die "case2: stdout mismatch (all-spaced manifest)"; fi
vault_check case2 "$tmp/src2" "$tmp/vault2" 2 "budget q3 v2.txt" "trip photos day 1.txt"

# Case 3 (stdin): four names, two of them containing spaces.
mkdir -p "$tmp/src3"
printf 'read this before running anything\n' > "$tmp/src3/read me first.txt"
printf 'standup notes\n' > "$tmp/src3/notes.txt"
printf 'rc payload 2024-11-08\n' > "$tmp/src3/release candidate.bin"
printf 'echo ok\n' > "$tmp/src3/run.sh"
cat > "$tmp/c3.list" <<'EOF'
read me first.txt
notes.txt
release candidate.bin
run.sh
EOF
cat > "$tmp/c3.exp" <<'EOF'
backed up: read me first.txt
backed up: notes.txt
backed up: release candidate.bin
backed up: run.sh
total: 4 file(s)
EOF
"$TO" 10 bash starter/main.sh - "$tmp/src3" "$tmp/vault3" < "$tmp/c3.list" > "$tmp/c3.out" 2> "$tmp/c3.err" || die "case3: exit $?, want 0"
if ! diff -u "$tmp/c3.exp" "$tmp/c3.out"; then die "case3: stdout mismatch (stdin manifest)"; fi
vault_check case3 "$tmp/src3" "$tmp/vault3" 4 "read me first.txt" notes.txt "release candidate.bin" run.sh

echo "METRIC: PASS bug-05"
exit 0
