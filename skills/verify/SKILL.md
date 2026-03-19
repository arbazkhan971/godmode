---
name: verify
description: Evidence gate. Run command, read output, confirm or deny claim.
---

## Activate When
- `/godmode:verify`, "prove it", "verify this"

## Workflow
1. **IDENTIFY** — Extract claim → pick verify command → define pass condition (exact string, numeric threshold, or exit code).
2. **RUN** — Execute exact command with `2>&1`. Full stdout+stderr. No filtering.
3. **READ** — Read entire output. Do not skim.
4. **JUDGE** — Compare pass condition vs actual output. Numeric metrics: 3 runs, use median. Boolean: single run.
5. **REPORT** — `Claim | Verified: YES/NO | Command | Output | Details`

## Rules
1. Run the command. Never verify in your head or accept without execution.
2. Read full output (stdout+stderr). Never filter or skim.
3. Partial pass = failure. 47/48 passing ≠ success. Non-zero exit = failure.
4. Stale results are invalid. Any code change since last run = re-run.
5. Metrics: median of 3 runs. Boolean: single run. Show full output with verdict.
