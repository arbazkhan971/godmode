# Unify the record-loading duplication (refactoring)

## Context

`starter/` holds `stockcheck`, a small Node CLI (CommonJS, no package.json) that inspects a records JSON file. Its three commands — `list`, `total`, and `ids` — each open the file, parse the JSON, and handle read/parse failures, using the same block copy-pasted three times. Last month a fix to the error messages was applied to two of the three copies and missed the third.

## Task

Unify the duplicated read + parse + error-handling block into a single shared loader, `function loadRecords(filePath)` defined under `starter/`, called by all three commands instead of re-implementing the loading. The refactor is purely mechanical: CLI behavior (stdout and exit codes) must stay exactly the same.

Make `bash metric.sh` exit 0.

## Constraints

- Do not modify `metric.sh`.
- Node built-ins only (CommonJS `require`); no `package.json`, no new dependencies.
- Work offline; no network access.
- Put all changes under `starter/`; keep the CLI entrypoint at `starter/index.js`.

## How to check

Run `bash metric.sh` here. Exit 0 = done.
