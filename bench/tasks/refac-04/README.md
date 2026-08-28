# Remove the dead feature-flag branches (refactoring)

## Context

`starter/` holds `wordbench`, a small Node CLI (CommonJS, no package.json) for quick text statistics, split across `index.js` (CLI dispatch), `textproc.js` (tokenizing and counting), and `render.js` (column layout). Months ago an alternate pipeline was trialed behind a `USE_EXPERIMENTAL` flag that was hard-coded to `false` in every module; the trial was abandoned, but the flag and the unreachable code paths it guards were never cleaned up.

## Task

Delete the `USE_EXPERIMENTAL` flag and every dead alternate path it guards, keeping only the live logic. After the refactor the abandoned trial must leave no trace under `starter/`: `grep -ri experimental starter | wc -l` must output 0, and no orphaned helpers may remain (every named function still defined under `starter/` must be called somewhere under `starter/`). The refactor is purely mechanical: CLI behavior (stdout and exit codes) must stay exactly the same.

Make `bash metric.sh` exit 0.

## Constraints

- Do not modify `metric.sh`.
- Node built-ins only (CommonJS `require`); no `package.json`, no new dependencies.
- Work offline; no network access.
- Put all changes under `starter/`; keep the CLI entrypoint at `starter/index.js`.

## How to check

Run `bash metric.sh` here. Exit 0 = done.
