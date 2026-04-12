---
name: terse
description: >
  Output-compression mode for long autonomous loops. Activates via
  GODMODE_TERSE=1 env var or /godmode:terse. Compresses round summaries,
  status lines, and agent reports 40-60% while preserving TSVs, code,
  errors, commit messages, and the final user-facing summary.
---

# Terse — Output Compression for Autonomous Loops

**Purpose.** Over a 20-round optimization loop, verbose prose summaries
dominate emitted tokens even though a human is rarely reading intermediate
rounds. Terse mode compresses the emit contract 40-60% without changing
the loop, the decisions, or the logged state. Inspired by caveman's
output-compression idea, restricted to what is safe for a structured,
TSV-driven workflow.

## Activate When

- `$GODMODE_TERSE` is set (any non-empty value)
- `/godmode:terse on` invoked (sets env var for the session)
- Auto-enable after 5+ consecutive rounds with no human interaction
  (orchestrator decides based on session-state.json)

Deactivate: `/godmode:terse off` or unset the env var.

## What Compresses

- Round summaries and status lines: `Round 7: kept change.` → `R7 keep`
- Agent reports: drop prose filler, keep field values
- Skill-level printed output: the `Godmode: ...` lines
- Intermediate "verify", "measure", "dispatching" progress prints

## What Stays Verbose (Never Compress)

- **TSV rows** — column count, delimiters, field meaning are contracts
- **Code blocks** — never touch syntax, never abbreviate identifiers
- **Error messages and stack traces** — full diagnostics always
- **Commit messages** — must remain git-log-readable and descriptive
- **Final summary** — the last line the user sees at session end
- **Success criteria commands** — shell commands stay literal
- **Failure classifications** — `scope_drift`, `noise`, `regression`,
  etc. are exact strings that downstream rules depend on

## Before / After Examples

Normal:
```
Round 7: Added connection pool sizing adjustment, verified with benchmark
(median of 3 runs), kept — metric improved from 276ms to 226ms (-18.2%).
```

Terse:
```
R7 keep: conn pool → 226ms (-18.2%)
```

Normal:
```
Builder Agent Report: Task implemented successfully. All 47 tests passing,
linter clean, no regressions in existing suite. 4 files modified, 2 files
created.
```

Terse:
```
Builder DONE: 47/47 tests, lint clean, 4 mod + 2 new.
```

Normal:
```
Godmode: stack=TypeScript, skill=optimize, phase=OPTIMIZE. Dispatching.
```

Terse:
```
GM: ts/opt/OPT dispatch.
```

## Compression Rules

1. **Emit-only.** Compress what you print. Never compress memory state,
   lessons.md, failures.tsv, session-state.json, or any file on disk.
2. **Structure preserved.** Same field order, same field count, same
   numbers. `(-18.2%)` stays `(-18.2%)`, not `(~-18%)`.
3. **Numeric precision unchanged.** 198ms stays 198ms, never rounded.
4. **Code never touched.** Diffs, snippets, and inline code are raw.
5. **Errors always full.** A failing test's stack trace is emitted in
   full regardless of terse mode.
6. **Final summary always verbose.** The last line of a session is the
   user's record — emit it in full prose.

## Integration Contract

Every skill SHOULD branch its output template on terse mode. Pattern:

```
IF $GODMODE_TERSE:
  print "R{round} {status}: {change} → {metric} ({delta}%)"
ELSE:
  print "Round {round}: {change}. {status}. Metric: {metric} ({delta}%)."
```

Both templates carry identical information — terse is a strict 1:1
compression, not a lossy summary. This is verifiable: parsing either
output MUST yield the same fields.

## Hard Rules

1. Terse is an output contract, not a behavior change. Loops, decisions,
   commits, reverts, and TSV writes are identical in both modes.
2. Never drop a field. "Keep" status without metric is incomplete.
3. Never compress user-facing errors. Silent truncation = lost evidence.
4. Never compress the final summary at session end.
5. TSV schemas are immutable. Terse mode does not touch column counts.

## Success Criterion

Over a 10-round loop with GODMODE_TERSE=1, total emitted tokens decrease
by at least 30% vs. baseline, AND:

- Same kept/discarded decisions
- Same TSV contents (byte-identical)
- Same commits (message content byte-identical)
- Same final summary (byte-identical)

Verify with:

```bash
# Run identical workflow twice
GODMODE_TERSE=0 /godmode:optimize 2>&1 | wc -c > baseline.bytes
git stash && git checkout HEAD~1  # reset state
GODMODE_TERSE=1 /godmode:optimize 2>&1 | wc -c > terse.bytes
echo "reduction: $(( 100 - 100 * $(cat terse.bytes) / $(cat baseline.bytes) ))%"
```

Target: ≥30% reduction. Accept ≥20% as success for short loops.

## Stop Conditions

- target_reached: emitted-token reduction ≥30%
- contract_violated: any field dropped or TSV row malformed → disable
  terse mode for rest of session, log incident
- user_opts_out: `/godmode:terse off` at any time

## Output Format

On activation (terse itself):
```
Terse: ON (mode=auto|explicit, baseline_tokens={N}, target_reduction=30%)
```

On deactivation:
```
Terse: OFF. Emitted={N} tokens, reduction={N}%, contract_violations={N}.
```
