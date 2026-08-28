#!/usr/bin/env bash
# metric refac-04: dead flag paths removed (0 'experimental' refs, no orphaned functions) with CLI behavior unchanged. Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout

[ -f starter/index.js ] || die "missing starter/index.js"

# --- behavior preservation: expected stdout/exit codes captured from the original starter ---
printf 'The quick brown fox jumps over the lazy dog.\nThe dog barks; the fox runs!\n' >"$tmp/sample.txt"
: >"$tmp/empty.txt"

check(){ # check <expected_rc> <expected_stdout_file> <argv...>
  local want_rc="$1" want_out="$2"; shift 2
  "$TO" 10 "$NODE" starter/index.js "$@" >"$tmp/got.out" 2>"$tmp/got.err"; local rc=$?
  [ "$rc" -eq "$want_rc" ] || die "behavior: 'index.js $*': exit $rc, want $want_rc"
  cmp -s "$want_out" "$tmp/got.out" || die "behavior: 'index.js $*': stdout mismatch"
}

printf '%s\n' '15 tokens' >"$tmp/e1"
cat >"$tmp/e2" <<'EOF'
the | 4
dog | 2
fox | 2
EOF
cat >"$tmp/e3" <<'EOF'
the   | 4
dog   | 2
fox   | 2
barks | 1
brown | 1
EOF
cat >"$tmp/e4" <<'EOF'
unique: 10
pipeline: stable
the | 4
dog | 2
fox | 2
EOF
cat >"$tmp/e5" <<'EOF'
unique: 0
pipeline: stable
EOF
printf '%s\n' '(no words)' >"$tmp/e6"
printf '%s\n' "error: cannot read $tmp/missing.txt" >"$tmp/e7"
printf '%s\n' 'error: n must be a positive integer' >"$tmp/e8"
printf '%s\n' 'usage: index.js {words|top|report} <textfile> [n]' >"$tmp/e9"

check 0 "$tmp/e1" words "$tmp/sample.txt"
check 0 "$tmp/e2" top "$tmp/sample.txt" 3
check 0 "$tmp/e3" top "$tmp/sample.txt" 5
check 0 "$tmp/e4" report "$tmp/sample.txt"
check 0 "$tmp/e5" report "$tmp/empty.txt"
check 0 "$tmp/e6" top "$tmp/empty.txt" 4
check 1 "$tmp/e7" words "$tmp/missing.txt"
check 1 "$tmp/e8" top "$tmp/sample.txt" x
check 2 "$tmp/e9"
check 2 "$tmp/e9" frobnicate "$tmp/sample.txt"

# --- structural goal: the abandoned flag trial leaves no trace ---
refs=$(grep -ri experimental starter | wc -l)
[ "$refs" -eq 0 ] || die "structure: 'experimental' must not appear under starter/, found on $refs lines"
for f in starter/*.js; do
  "$TO" 10 "$NODE" --check "$f" || die "structure: $f does not parse"
done
cat >"$tmp/orphans.js" <<'EOF'
/* every named function defined under starter/ must still be called somewhere under starter/ */
"use strict";
const fs = require("fs");
const path = require("path");
function listJs(dir, acc) {
  for (const e of fs.readdirSync(dir, { withFileTypes: true })) {
    const p = path.join(dir, e.name);
    if (e.isDirectory()) listJs(p, acc);
    else if (e.name.endsWith(".js")) acc.push(p);
  }
  return acc;
}
const files = listJs("starter", []);
let bad = "";
for (const f of files) {
  const src = fs.readFileSync(f, "utf8");
  const defs = src.match(/^[ \t]*function ([A-Za-z0-9_]+)\s*\(/gm) || [];
  for (const d of defs) {
    const name = d.replace(/^[ \t]*function /, "").replace(/\s*\($/, "");
    let uses = 0;
    for (const g of files) {
      const re = new RegExp("\\b" + name + "\\s*\\(", "g");
      uses += (fs.readFileSync(g, "utf8").match(re) || []).length;
    }
    if (uses < 2) bad += f + ": function '" + name + "' is defined but never called\n";
  }
}
if (bad) {
  console.error(bad.trim());
  process.exit(1);
}
EOF
"$TO" 10 "$NODE" "$tmp/orphans.js" || die "structure: orphaned functions remain under starter/"

echo "METRIC: PASS refac-04"
exit 0
