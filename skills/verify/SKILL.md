---
name: verify
description: Evidence gate. Run command, read output, confirm or deny claim.
---

## Activate When
- `/godmode:verify`, "prove it", "verify this"

## Workflow
1. **IDENTIFY** — Extract claim → pick verify command → define pass/fail (exact string match, threshold comparison, or exit code 0).
2. **RUN** — Execute: `cmd 2>&1 | tee /tmp/verify-output.txt`. Capture full stdout+stderr. No filtering, no truncation.
3. **READ** — Parse entire output line by line. Check for warnings, errors, and unexpected values.
4. **JUDGE** — Compare expected vs actual. Numeric: 3 runs, median. Boolean: 1 run. Ambiguous output = FAIL.
5. **REPORT** — `Claim | Result: PASS/FAIL | Command | Expected | Actual | Details`

## Rules
1. Run the command. Never verify in your head. Never trust cached results. Never accept 'it should work'.
2. Read full output (stdout+stderr). Never filter or skim.
3. Partial pass = failure (47/48 ≠ success). Non-zero exit = failure. Timeout = failure.
4. Stale = invalid. If `git status` shows changes since last verify → re-run. No exceptions.
5. Metrics: median of 3 runs. Boolean: single run. Always show: command, full output, verdict.
