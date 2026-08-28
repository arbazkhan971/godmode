#!/usr/bin/env bash
# metric bug-04: index.js must report upload completion only after every manifest artifact has settled in the vault (file and stdin manifests). Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout

[ -f starter/index.js ] || die "missing starter/index.js"

# After a run, the vault must hold exactly $4 files (newline-safe NUL listing),
# each byte-identical to its staging copy.
vault_check(){ # $1=case-label $2=staging $3=vault $4=count  rest=names
  local label=$1 staging=$2 vault=$3 want=$4 name n=0 f
  shift 4
  while IFS= read -r -d '' f; do n=$((n+1)); done < <("$TO" 5 find "$vault" -maxdepth 1 -type f -print0)
  [ "$n" -eq "$want" ] || die "$label: vault holds $n file(s) after exit, want $want"
  for name in "$@"; do
    "$TO" 5 cmp -s "$staging/$name" "$vault/$name" || die "$label: $name missing or differs in vault"
  done
}

# Case 1 (argv): three artifacts; manifest order is not alphabetical.
mkdir -p "$tmp/src1"
printf 'build started\ncompile ok\npackaged 3 artifacts\n' > "$tmp/src1/build.log"
printf '<svg>ok</svg>\n' > "$tmp/src1/badge.svg"
printf 'nightly build notes\n' > "$tmp/src1/notes.txt"
printf 'build.log\nbadge.svg\nnotes.txt\n' > "$tmp/c1.list"
cat > "$tmp/c1.exp" <<'EOF'
stored build.log (46 bytes)
stored badge.svg (14 bytes)
stored notes.txt (20 bytes)
EOF
printf 'upload complete: 3 file(s) -> %s\n' "$tmp/vault1" >> "$tmp/c1.exp"
"$TO" 10 "$NODE" starter/index.js "$tmp/src1" "$tmp/c1.list" "$tmp/vault1" > "$tmp/c1.out" 2> "$tmp/c1.err" || die "case1: exit $?, want 0"
if ! diff -u "$tmp/c1.exp" "$tmp/c1.out"; then die "case1: stdout mismatch (3-artifact manifest)"; fi
vault_check case1 "$tmp/src1" "$tmp/vault1" 3 build.log badge.svg notes.txt

# Case 2 (argv): single artifact — even a one-file upload must settle before the summary.
mkdir -p "$tmp/src2"
printf 'pkg:solo:v1\n' > "$tmp/src2/solo.bin"
printf 'solo.bin\n' > "$tmp/c2.list"
printf 'stored solo.bin (12 bytes)\nupload complete: 1 file(s) -> %s\n' "$tmp/vault2" > "$tmp/c2.exp"
"$TO" 10 "$NODE" starter/index.js "$tmp/src2" "$tmp/c2.list" "$tmp/vault2" > "$tmp/c2.out" 2> "$tmp/c2.err" || die "case2: exit $?, want 0"
if ! diff -u "$tmp/c2.exp" "$tmp/c2.out"; then die "case2: stdout mismatch (single-artifact manifest)"; fi
vault_check case2 "$tmp/src2" "$tmp/vault2" 1 solo.bin

# Case 3 (stdin): four artifacts in non-alphabetical manifest order.
mkdir -p "$tmp/src3"
printf 'first artifact\n' > "$tmp/src3/alpha.txt"
printf 'second artifact with more bytes\n' > "$tmp/src3/beta.bin"
printf '# gamma\nbody line\n' > "$tmp/src3/gamma.md"
printf 't=1 ok\nt=2 ok\n' > "$tmp/src3/delta.log"
printf 'beta.bin\nalpha.txt\ndelta.log\ngamma.md\n' > "$tmp/c3.list"
cat > "$tmp/c3.exp" <<'EOF'
stored beta.bin (32 bytes)
stored alpha.txt (15 bytes)
stored delta.log (14 bytes)
stored gamma.md (18 bytes)
EOF
printf 'upload complete: 4 file(s) -> %s\n' "$tmp/vault3" >> "$tmp/c3.exp"
"$TO" 10 "$NODE" starter/index.js "$tmp/src3" - "$tmp/vault3" < "$tmp/c3.list" > "$tmp/c3.out" 2> "$tmp/c3.err" || die "case3: exit $?, want 0"
if ! diff -u "$tmp/c3.exp" "$tmp/c3.out"; then die "case3: stdout mismatch (stdin manifest)"; fi
vault_check case3 "$tmp/src3" "$tmp/vault3" 4 beta.bin alpha.txt delta.log gamma.md

echo "METRIC: PASS bug-04"
exit 0
