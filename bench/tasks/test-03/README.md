# Markup tokenizer test suite (test-writing)

## Context

`starter/` holds a note-taking tool's tokenizer: `markup.js` (CommonJS) turns one line of lightweight markup into an ordered token list — `**bold**` spans, `*italic*` spans, and plain text — with backslash escapes (`\*` is a literal `*`), literal handling of unmatched markers, and no tokens for an empty line. `index.js` is a demo CLI that prints the token list as JSON. The tokenizer has no tests and the next release depends on it.

## Task

Write a test suite under `starter/tests/` (files named `*_test.js`) using the built-in `node:test` runner with `node:assert`. Require the implementation by relative path: `require("../markup")`. The suite must demonstrate the tokenizer's documented behavior by importing and calling it — including its edge cases — not by reading its source text. Make `bash metric.sh` exit 0.

## Constraints

- Do not modify `metric.sh`.
- Node built-in modules only; no npm packages, no `package.json`.
- Work offline; no network access.
- Put all changes under `starter/tests/`.
- Do not modify `starter/markup.js` or `starter/index.js`.

## How to check

Run `bash metric.sh` here. Exit 0 = done.
