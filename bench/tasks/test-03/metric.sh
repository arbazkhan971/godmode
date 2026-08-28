#!/usr/bin/env bash
# metric test-03: agent suite must pass pristine markup.js and fail on 3 seeded mutants. Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout

IMPL=markup.js
TESTS=starter/tests

[ -f "starter/$IMPL" ] || die "missing starter/$IMPL"
[ -d "$TESTS" ] || die "no tests yet: write node:test suites under starter/tests/ as *_test.js"
ls "$TESTS"/*_test.js >/dev/null 2>&1 || die "no *_test.js files under $TESTS"

run_case(){  # $1=variant label; impl source on stdin; returns the suite's exit status
  local case_dir="$tmp/case-$1"
  mkdir -p "$case_dir/tests"
  cat > "$case_dir/$IMPL"
  cp -r "$TESTS"/. "$case_dir/tests/"
  ( cd "$case_dir" && "$TO" 15 "$NODE" --test tests/ ) >/dev/null 2>&1
}

# Variant: pristine implementation -> the suite must pass.
run_case pristine <<'IMPL'
"use strict";

// Tokenize one line of lightweight markup into an ordered token list:
//   **text** -> { kind: "bold", text: "..." }
//   *text*   -> { kind: "italic", text: "..." }
//   anything else accumulates into { kind: "text", text: "..." }
// A backslash escapes the next character (\* is a literal "*", \\ a literal "\").
// Unmatched markers stay literal; an empty line yields no tokens.

function tokenize(line) {
  const tokens = [];
  let buf = "";
  let i = 0;
  const flush = () => {
    if (buf.length > 0) {
      tokens.push({ kind: "text", text: buf });
      buf = "";
    }
  };
  while (i < line.length) {
    const ch = line[i];
    if (ch === "\\") {
      const next = line[i + 1];
      if (next === undefined) {
        buf += "\\";
        i += 1;
      } else {
        buf += next;
        i += 2;
      }
    } else if (ch === "*" && line[i + 1] === "*") {
      const close = line.indexOf("**", i + 2);
      if (close === -1) {
        buf += "**";
        i += 2;
      } else {
        flush();
        tokens.push({ kind: "bold", text: line.slice(i + 2, close) });
        i = close + 2;
      }
    } else if (ch === "*") {
      const close = line.indexOf("*", i + 1);
      if (close === -1) {
        buf += "*";
        i += 1;
      } else {
        flush();
        tokens.push({ kind: "italic", text: line.slice(i + 1, close) });
        i = close + 1;
      }
    } else {
      buf += ch;
      i += 1;
    }
  }
  flush();
  return tokens;
}

module.exports = { tokenize };
IMPL
rc=$?; [ "$rc" -eq 0 ] || die "suite fails on the pristine implementation (rc=$rc) - fix the tests, not the impl"

# Mutant 1: escapes keep the backslash instead of unescaping the next char.
run_case m_escape <<'IMPL'
"use strict";

// Tokenize one line of lightweight markup into an ordered token list:
//   **text** -> { kind: "bold", text: "..." }
//   *text*   -> { kind: "italic", text: "..." }
//   anything else accumulates into { kind: "text", text: "..." }
// A backslash escapes the next character (\* is a literal "*", \\ a literal "\").
// Unmatched markers stay literal; an empty line yields no tokens.

function tokenize(line) {
  const tokens = [];
  let buf = "";
  let i = 0;
  const flush = () => {
    if (buf.length > 0) {
      tokens.push({ kind: "text", text: buf });
      buf = "";
    }
  };
  while (i < line.length) {
    const ch = line[i];
    if (ch === "\\") {
      const next = line[i + 1];
      if (next === undefined) {
        buf += "\\";
        i += 1;
      } else {
        buf += ch + next;
        i += 2;
      }
    } else if (ch === "*" && line[i + 1] === "*") {
      const close = line.indexOf("**", i + 2);
      if (close === -1) {
        buf += "**";
        i += 2;
      } else {
        flush();
        tokens.push({ kind: "bold", text: line.slice(i + 2, close) });
        i = close + 2;
      }
    } else if (ch === "*") {
      const close = line.indexOf("*", i + 1);
      if (close === -1) {
        buf += "*";
        i += 1;
      } else {
        flush();
        tokens.push({ kind: "italic", text: line.slice(i + 1, close) });
        i = close + 1;
      }
    } else {
      buf += ch;
      i += 1;
    }
  }
  flush();
  return tokens;
}

module.exports = { tokenize };
IMPL
rc=$?; [ "$rc" -ne 0 ] || die "mutant m_escape survived - escape handling is untested"

# Mutant 2: empty buffers flush too, so empty lines emit an empty text token.
run_case m_empty <<'IMPL'
"use strict";

// Tokenize one line of lightweight markup into an ordered token list:
//   **text** -> { kind: "bold", text: "..." }
//   *text*   -> { kind: "italic", text: "..." }
//   anything else accumulates into { kind: "text", text: "..." }
// A backslash escapes the next character (\* is a literal "*", \\ a literal "\").
// Unmatched markers stay literal; an empty line yields no tokens.

function tokenize(line) {
  const tokens = [];
  let buf = "";
  let i = 0;
  const flush = () => {
    if (buf.length >= 0) {
      tokens.push({ kind: "text", text: buf });
      buf = "";
    }
  };
  while (i < line.length) {
    const ch = line[i];
    if (ch === "\\") {
      const next = line[i + 1];
      if (next === undefined) {
        buf += "\\";
        i += 1;
      } else {
        buf += next;
        i += 2;
      }
    } else if (ch === "*" && line[i + 1] === "*") {
      const close = line.indexOf("**", i + 2);
      if (close === -1) {
        buf += "**";
        i += 2;
      } else {
        flush();
        tokens.push({ kind: "bold", text: line.slice(i + 2, close) });
        i = close + 2;
      }
    } else if (ch === "*") {
      const close = line.indexOf("*", i + 1);
      if (close === -1) {
        buf += "*";
        i += 1;
      } else {
        flush();
        tokens.push({ kind: "italic", text: line.slice(i + 1, close) });
        i = close + 1;
      }
    } else {
      buf += ch;
      i += 1;
    }
  }
  flush();
  return tokens;
}

module.exports = { tokenize };
IMPL
rc=$?; [ "$rc" -ne 0 ] || die "mutant m_empty survived - empty-line handling is untested"

# Mutant 3: an unclosed ** marker is dropped from the text instead of kept literal.
run_case m_unclosed <<'IMPL'
"use strict";

// Tokenize one line of lightweight markup into an ordered token list:
//   **text** -> { kind: "bold", text: "..." }
//   *text*   -> { kind: "italic", text: "..." }
//   anything else accumulates into { kind: "text", text: "..." }
// A backslash escapes the next character (\* is a literal "*", \\ a literal "\").
// Unmatched markers stay literal; an empty line yields no tokens.

function tokenize(line) {
  const tokens = [];
  let buf = "";
  let i = 0;
  const flush = () => {
    if (buf.length > 0) {
      tokens.push({ kind: "text", text: buf });
      buf = "";
    }
  };
  while (i < line.length) {
    const ch = line[i];
    if (ch === "\\") {
      const next = line[i + 1];
      if (next === undefined) {
        buf += "\\";
        i += 1;
      } else {
        buf += next;
        i += 2;
      }
    } else if (ch === "*" && line[i + 1] === "*") {
      const close = line.indexOf("**", i + 2);
      if (close === -1) {
        buf += "";
        i += 2;
      } else {
        flush();
        tokens.push({ kind: "bold", text: line.slice(i + 2, close) });
        i = close + 2;
      }
    } else if (ch === "*") {
      const close = line.indexOf("*", i + 1);
      if (close === -1) {
        buf += "*";
        i += 1;
      } else {
        flush();
        tokens.push({ kind: "italic", text: line.slice(i + 1, close) });
        i = close + 1;
      }
    } else {
      buf += ch;
      i += 1;
    }
  }
  flush();
  return tokens;
}

module.exports = { tokenize };
IMPL
rc=$?; [ "$rc" -ne 0 ] || die "mutant m_unclosed survived - unclosed-marker handling is untested"

echo "METRIC: PASS test-03"
exit 0
