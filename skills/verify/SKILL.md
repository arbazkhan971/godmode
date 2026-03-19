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
1. NEVER accept a claim without running the command.
2. NEVER verify in your head. Run it.
3. NEVER ignore partial failures. 47/48 passing = failure.
4. NEVER accept stale verification. Changes since last run = re-run.
5. NEVER filter output before reading it.
6. ALWAYS use median of 3 runs for metrics.
7. ALWAYS show full output alongside parsed result.
8. Non-zero exit code = failure, regardless of stdout.
