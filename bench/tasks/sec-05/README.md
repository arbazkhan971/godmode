# Sanitize eval in the log filter (security-hardening)

## Context
`logfilter` keeps the lines of a log that satisfy a per-line test and is run
by engineers on logs pasted in from anywhere: CI output, customer uploads,
chat transcripts. Tests are written as bash conditionals over `$line` (the
current line) and `$n` (its 1-based number), for example
`'[[ $line == *ERROR* ]]'` or `'[[ $n -ge 3 && $line != *DEBUG* ]]'`.

## Task
Make `logfilter` safe to hand any test string: a test must only ever decide
which lines are kept — it must never execute commands, run substitutions, or
touch anything outside the log being filtered. A test that cannot be
evaluated safely must be rejected with a diagnostic on stderr and a nonzero
exit before any line is printed. The documented conditionals shown above
must keep selecting exactly the same lines as they do today.
Make `bash metric.sh` exit 0.

## Constraints
- Do not modify `metric.sh`.
- Bash only (no other interpreters called out); no network.
- Put all changes under `starter/`.

## How to check
Run `bash metric.sh` here. Exit 0 = done.
