---
name: verify
description: |
  Evidence gate. Runs verification commands and confirms or denies claims. Triggers on: /godmode:verify, internally before any skill claims success, or "prove it" / "verify this."
---

# Verify — Evidence Before Claims

## Activate When
- `/godmode:verify` or "prove it," "show me," "verify that works"
- Any skill needs to confirm a claim before reporting it
- After any change that claims an improvement or fix

## Workflow
1. **IDENTIFY** — Extract the claim, choose the verify command, define expected output.
2. **RUN** — Execute the exact command with `2>&1`. Capture full stdout+stderr. No filtering, no truncation.
3. **READ** — Read the entire output. Do not skim or assume.
4. **JUDGE** — Compare expected vs actual. For metrics: run 3 times, use median.
5. **REPORT** — Return verdict: `Claim | Verified: YES/NO | Command | Output | Details (if rejected)`.

## Key Behaviors
- Run, don't assume. "I already ran this" is not verification.
- Read full output. Don't grep for "passing" and ignore the rest.
- Three-run median for all metric claims.
- Report honestly. Don't soften bad news.
- Include the raw output so the user/caller can confirm.
- Exit codes matter. Prints "success" but exits non-zero = failure.

## HARD RULES
1. NEVER accept a claim without running the verification command.
2. NEVER verify in your head. "Code looks correct" is not verification. Run the command.
3. NEVER ignore partial failures. 47/48 passing = failure.
4. NEVER accept stale verification. Changes since last run = re-run.
5. NEVER filter output before reading it.
6. ALWAYS use median of 3 runs for metric verification.
7. ALWAYS show full command output alongside the parsed result.
8. NEVER mark a claim verified if exit code is non-zero.
