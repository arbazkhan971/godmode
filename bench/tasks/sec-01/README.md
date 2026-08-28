# Block path traversal in the file server (security-hardening)

## Context
`miniserve` is a tiny read-only file server used by a docs pipeline. It is
invoked as a CLI: given a document root and a relative file name, it prints
that file's contents. Deployments serve one fixed document root and must never
expose anything outside it.

## Task
Harden `miniserve` so a request can only ever read files inside the document
root it was given. Any request that names a file outside the root must be
refused with a nonzero exit code and must not print the target's contents.
Requests for ordinary files inside the root must keep behaving exactly as they
do today, and a missing in-root file must still fail cleanly.
Make `bash metric.sh` exit 0.

## Constraints
- Do not modify `metric.sh`.
- Python 3 standard library only; no third-party packages; no network.
- Put all changes under `starter/`.

## How to check
Run `bash metric.sh` here. Exit 0 = done.
