# Escape HTML in the template renderer (security-hardening)

## Context
`pagegen` renders small HTML fragments for the build-status page. Templates
live in the repo, but the values substituted into them come straight from job
names, branch names, and other user-controlled strings. The generated
fragments are embedded in a dashboard that everyone in the org opens.

## Task
Make the rendered output safe: a value must never be able to introduce HTML
markup or scripts into a generated fragment. Values that contain markup
characters must still appear, textually, in the output; the template's own
markup and all plain-text values must render exactly as before.
Make `bash metric.sh` exit 0.

## Constraints
- Do not modify `metric.sh`.
- Node standard library only (no npm packages); no network.
- Put all changes under `starter/`.

## How to check
Run `bash metric.sh` here. Exit 0 = done.
