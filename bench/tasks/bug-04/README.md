# Nightly artifact uploader (bug-fixing)

## Context

`starter/` is the nightly-build uploader: `index.js` reads a manifest of artifact names and hands them to `uploader.js`, which stores each staged artifact into the destination vault while the CLI prints a progress report. The release dashboard links straight to the vault contents the moment this tool reports completion.

## Task

Make the uploader's report truthful for both file and stdin manifests: each artifact must be reported stored in manifest order, and the completion summary may only appear once every artifact named in the manifest has actually settled in the destination. Make `bash metric.sh` exit 0.

## Constraints

- Do not modify `metric.sh`.
- Node core modules only (`fs`, `path`); CommonJS `require`, no npm packages, no `package.json`.
- Work offline; no network access.
- Put all changes under `starter/`.

## How to check

Run `bash metric.sh` here. Exit 0 = done.
