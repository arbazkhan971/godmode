# Deque test suite (test-writing)

## Context

`starter/` holds the queue primitive from a small job-runner: `deque.js` (CommonJS) implements a double-ended queue — `pushBack`/`pushFront` return the new size, `popBack`/`popFront` remove and return the item at that end, `peekBack`/`peekFront` look without removing, and `size` counts items. Pops and peeks on an empty deque return `null` (never `undefined`). `index.js` is a demo CLI that prints a push/pop transcript. The module has no tests and new features land next sprint.

## Task

Write a test suite under `starter/tests/` (files named `*_test.js`) using the built-in `node:test` runner with `node:assert`. Require the implementation by relative path: `require("../deque")`. The suite must demonstrate the queue's documented behavior by importing and calling it — including its edge cases — not by reading its source text. Make `bash metric.sh` exit 0.

## Constraints

- Do not modify `metric.sh`.
- Node built-in modules only; no npm packages, no `package.json`.
- Work offline; no network access.
- Put all changes under `starter/tests/`.
- Do not modify `starter/deque.js` or `starter/index.js`.

## How to check

Run `bash metric.sh` here. Exit 0 = done.
