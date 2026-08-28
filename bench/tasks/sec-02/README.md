# Stop shell injection in the thumbnail command (security-hardening)

## Context
`thumbs` is a small utility used by a media pipeline. For every asset it asks
the local digest backend (`sha256sum`) for a fingerprint that downstream jobs
key on. Filenames arrive from user uploads, so they can contain spaces,
semicolons, or other shell metacharacters.

## Task
Harden the digest path so that a filename is only ever processed as a single
argument. Processing a malicious filename must not let shell commands embedded
in it execute, must not print a digest for it, and must fail with a nonzero
exit. Benign filenames — including ones with spaces — must keep producing
exactly the same digest output as today, for both single files and batch runs.
Make `bash metric.sh` exit 0.

## Constraints
- Do not modify `metric.sh`.
- Python 3 standard library only; no third-party packages; no network.
- Put all changes under `starter/`.

## How to check
Run `bash metric.sh` here. Exit 0 = done.
