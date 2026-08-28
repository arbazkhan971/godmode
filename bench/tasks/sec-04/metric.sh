#!/usr/bin/env bash
# metric sec-04: pagegen must escape untrusted values while trusted markup and plain text render byte-identically. Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout

[ -f starter/index.js ] || die "missing starter/index.js"

# crafted payload: a value that is itself markup must come out escaped, not live
out="$($TO 5 "$NODE" starter/index.js '<p>Hello, {name}!</p>' 'name=<script>alert(1)</script>' 2>/dev/null)"; rc=$?
[ "$rc" -eq 0 ] || die "payload: exit $rc, want 0"
[ "$out" = '<p>Hello, &lt;script&gt;alert(1)&lt;/script&gt;!</p>' ] || die "payload: value injected raw: $out"

# crafted payload 2: ampersand is markup too (invalid HTML if left raw)
out="$($TO 5 "$NODE" starter/index.js 'Welcome, {name}!' 'name=AT&T Labs' 2>/dev/null)"; rc=$?
[ "$rc" -eq 0 ] || die "ampersand: exit $rc, want 0"
[ "$out" = 'Welcome, AT&amp;T Labs!' ] || die "ampersand: not escaped: $out"

# escaping must hit values only, never the template's own markup
out="$($TO 5 "$NODE" starter/index.js '<div class="k">{msg}</div>' 'msg=<script>alert(1)</script>' 2>/dev/null)"; rc=$?
[ "$rc" -eq 0 ] || die "markup: exit $rc, want 0"
[ "$out" = '<div class="k">&lt;script&gt;alert(1)&lt;/script&gt;</div>' ] || die "markup: template markup must stay literal, value escaped: $out"

# benign: plain-text values render byte-identically
out="$($TO 5 "$NODE" starter/index.js 'Hello, {name}!' 'name=Alice' 2>/dev/null)"; rc=$?
[ "$rc" -eq 0 ] || die "benign 1: exit $rc, want 0"
[ "$out" = 'Hello, Alice!' ] || die "benign 1: got '$out'"

out="$($TO 5 "$NODE" starter/index.js '<li>{item} x{qty}</li>' item=Widget qty=3 2>/dev/null)"; rc=$?
[ "$rc" -eq 0 ] || die "benign 2: exit $rc, want 0"
[ "$out" = '<li>Widget x3</li>' ] || die "benign 2: got '$out'"

# behavior preserved: an undefined placeholder still fails cleanly
out="$($TO 5 "$NODE" starter/index.js 'Hi {missing}' name=Alice 2>/dev/null)"; rc=$?
[ "$rc" -eq 3 ] || die "undefined variable: exit $rc, want 3"
[ -z "$out" ] || die "undefined variable: unexpected stdout"

echo "METRIC: PASS sec-04"
exit 0
