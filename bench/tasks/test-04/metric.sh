#!/usr/bin/env bash
# metric test-04: agent suite must pass pristine deque.js and fail on 3 seeded mutants. Immutable during benchmark runs (runner SHA256-checksums this file).
set -uo pipefail
cd "$(dirname "$0")"
export LC_ALL=C TZ=UTC PYTHONHASHSEED=0
unset PYTHONPATH PYTHONSTARTUP BASH_ENV NODE_OPTIONS NODE_PATH
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
die(){ echo "METRIC: FAIL: $1"; exit 1; }
PY=/usr/bin/python3; NODE=/usr/bin/node; TO=/usr/bin/timeout

IMPL=deque.js
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

// Double-ended queue used by the job runner: items can be added and removed
// at either end. Pops and peeks on an empty deque return null (never
// undefined) so callers can tell "empty" apart from any stored value.

class Deque {
  constructor() {
    this._items = [];
  }

  // Add value at the back; returns the new size.
  pushBack(value) {
    this._items.push(value);
    return this._items.length;
  }

  // Add value at the front; returns the new size.
  pushFront(value) {
    this._items.unshift(value);
    return this._items.length;
  }

  // Remove and return the back item, or null when empty.
  popBack() {
    if (this._items.length === 0) return null;
    return this._items.pop();
  }

  // Remove and return the front item, or null when empty.
  popFront() {
    if (this._items.length === 0) return null;
    return this._items.shift();
  }

  // Return the back item without removing it, or null when empty.
  peekBack() {
    if (this._items.length === 0) return null;
    return this._items[this._items.length - 1];
  }

  // Return the front item without removing it, or null when empty.
  peekFront() {
    if (this._items.length === 0) return null;
    return this._items[0];
  }

  // Number of items currently held.
  size() {
    return this._items.length;
  }
}

module.exports = { Deque };
IMPL
rc=$?; [ "$rc" -eq 0 ] || die "suite fails on the pristine implementation (rc=$rc) - fix the tests, not the impl"

# Mutant 1: popBack removes the second-to-last item instead of the last.
run_case m_popback <<'IMPL'
"use strict";

// Double-ended queue used by the job runner: items can be added and removed
// at either end. Pops and peeks on an empty deque return null (never
// undefined) so callers can tell "empty" apart from any stored value.

class Deque {
  constructor() {
    this._items = [];
  }

  // Add value at the back; returns the new size.
  pushBack(value) {
    this._items.push(value);
    return this._items.length;
  }

  // Add value at the front; returns the new size.
  pushFront(value) {
    this._items.unshift(value);
    return this._items.length;
  }

  // Remove and return the back item, or null when empty.
  popBack() {
    if (this._items.length === 0) return null;
    return this._items.splice(this._items.length - 2, 1)[0];
  }

  // Remove and return the front item, or null when empty.
  popFront() {
    if (this._items.length === 0) return null;
    return this._items.shift();
  }

  // Return the back item without removing it, or null when empty.
  peekBack() {
    if (this._items.length === 0) return null;
    return this._items[this._items.length - 1];
  }

  // Return the front item without removing it, or null when empty.
  peekFront() {
    if (this._items.length === 0) return null;
    return this._items[0];
  }

  // Number of items currently held.
  size() {
    return this._items.length;
  }
}

module.exports = { Deque };
IMPL
rc=$?; [ "$rc" -ne 0 ] || die "mutant m_popback survived - back-end removal is untested"

# Mutant 2: popFront on an empty deque returns undefined instead of null.
run_case m_empty <<'IMPL'
"use strict";

// Double-ended queue used by the job runner: items can be added and removed
// at either end. Pops and peeks on an empty deque return null (never
// undefined) so callers can tell "empty" apart from any stored value.

class Deque {
  constructor() {
    this._items = [];
  }

  // Add value at the back; returns the new size.
  pushBack(value) {
    this._items.push(value);
    return this._items.length;
  }

  // Add value at the front; returns the new size.
  pushFront(value) {
    this._items.unshift(value);
    return this._items.length;
  }

  // Remove and return the back item, or null when empty.
  popBack() {
    if (this._items.length === 0) return null;
    return this._items.pop();
  }

  // Remove and return the front item, or null when empty.
  popFront() {
    return this._items.shift();
  }

  // Return the back item without removing it, or null when empty.
  peekBack() {
    if (this._items.length === 0) return null;
    return this._items[this._items.length - 1];
  }

  // Return the front item without removing it, or null when empty.
  peekFront() {
    if (this._items.length === 0) return null;
    return this._items[0];
  }

  // Number of items currently held.
  size() {
    return this._items.length;
  }
}

module.exports = { Deque };
IMPL
rc=$?; [ "$rc" -ne 0 ] || die "mutant m_empty survived - empty-deque handling is untested"

# Mutant 3: peekFront reads the back end instead of the front end.
run_case m_peekfront <<'IMPL'
"use strict";

// Double-ended queue used by the job runner: items can be added and removed
// at either end. Pops and peeks on an empty deque return null (never
// undefined) so callers can tell "empty" apart from any stored value.

class Deque {
  constructor() {
    this._items = [];
  }

  // Add value at the back; returns the new size.
  pushBack(value) {
    this._items.push(value);
    return this._items.length;
  }

  // Add value at the front; returns the new size.
  pushFront(value) {
    this._items.unshift(value);
    return this._items.length;
  }

  // Remove and return the back item, or null when empty.
  popBack() {
    if (this._items.length === 0) return null;
    return this._items.pop();
  }

  // Remove and return the front item, or null when empty.
  popFront() {
    if (this._items.length === 0) return null;
    return this._items.shift();
  }

  // Return the back item without removing it, or null when empty.
  peekBack() {
    if (this._items.length === 0) return null;
    return this._items[this._items.length - 1];
  }

  // Return the front item without removing it, or null when empty.
  peekFront() {
    if (this._items.length === 0) return null;
    return this._items[this._items.length - 1];
  }

  // Number of items currently held.
  size() {
    return this._items.length;
  }
}

module.exports = { Deque };
IMPL
rc=$?; [ "$rc" -ne 0 ] || die "mutant m_peekfront survived - front-end peeking is untested"

echo "METRIC: PASS test-04"
exit 0
