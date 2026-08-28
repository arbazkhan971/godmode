# Release vault backup (bug-fixing)

## Context

`starter/` is the release team's vault-pack script: `main.sh` reads a manifest naming files staged from the latest build and copies each one into the backup vault, printing what it stored and a closing total. The release coordinator runs it right before tagging a build.

## Task

Make the script back up every file named in the manifest exactly as named, for both file and stdin manifests: each manifest line names one staged file, the run must report each backed-up file and a matching total, and the vault must end up holding exactly the manifest's files with identical contents. Make `bash metric.sh` exit 0.

## Constraints

- Do not modify `metric.sh`.
- Bash with coreutils only; no other interpreters or packages.
- Work offline; no network access.
- Put all changes under `starter/`.

## How to check

Run `bash metric.sh` here. Exit 0 = done.
