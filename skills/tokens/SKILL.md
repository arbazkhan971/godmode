---
name: tokens
description: Token-budget observability for godmode loops. Measures approximate input + output tokens consumed by each round of the Universal Protocol, appends one row per round to .godmode/token-log.tsv, and emits a terse session-end summary with per-skill breakdown and delta vs. prior sessions. Read-only to source. Inspired by rtk-ai/rtk's `gain`, `discover`, and `session` analytics. Fills the observability gap next to results.tsv (metric deltas) and failures.tsv (discard reasons) — tokens.tsv answers "what did this round COST in context?"
---

## Activate When
- `/godmode:tokens`, "token budget", "how expensive was this loop", "context cost"
- Any multi-round skill (optimize, refactor, debug, bench, terse) that runs a loop with DECIDE/LOG boundaries
- At session end, when the user asks "is my token usage trending up or down?"
- NOT for live streaming or real-time metering — this is append-per-round observability only. If you want a live meter, use a shell prompt, not this skill.
- Opt-out: if `GODMODE_TOKENS=0` is set in the environment, this skill is a no-op. Privacy-sensitive workflows (medical, secrets, PII sweeps) can set this to disable all round-size logging for the session. Opt-out is sticky per session; never overridden by auto-activation.

## Inputs
Ask once, cache for the session:
- `session_id` — stable id for the run. Default: `date +%s` at session start, reused across every round.
- `skill` — the skill driving the current round (read from session-state.json, not re-asked).
- `round` — monotonic counter, read from session-state.json.
- `terse_on` — boolean. `1` if `$GODMODE_TERSE` is non-empty, else `0`.
- `rtk_detected` — `1` if `command -v rtk` returns zero, else `0`. Logged as environment context, not used for computation.

## Workflow
At each round boundary — specifically AFTER the DECIDE/LOG step of the Universal Protocol, so a full round has been emitted:

1. Skip entirely if `GODMODE_TOKENS=0`. Emit nothing, write nothing.
2. Measure `input_chars` — sum of bytes of all files READ during this round plus the emit text of the prior round. Source: session-state.json's `round_context_files` array (maintained by the orchestrator) and `.godmode/last-round-emit.txt` (atomically rewritten after every round).
3. Measure `output_chars` — byte count of the current round's emit text, captured into `.godmode/last-round-emit.txt` as the round closes.
4. Convert to approximate tokens via the heuristic in the "Token Heuristic" section below.
5. Read the prior `cumulative_tokens` for this `session_id` from the last matching row of `.godmode/token-log.tsv`. Default 0 for round 1.
6. Append ONE row to `.godmode/token-log.tsv` with the schema in "TSV Schema".
7. Roll over the log if row count exceeds 10000 (see "Log Rotation").

At session end (any stop_reason), emit the summary described in "Output Format".

## Token Heuristic
Exact tokenization varies per model and is not worth a dependency on model-specific libraries for an observability skill. This skill uses one explicit, reproducible rule:

```
approx_tokens = ceil(char_count / 4)
```

Rationale: for English prose and code, 1 token averages ~3.8-4.2 characters across GPT-4, Claude, and Llama tokenizers. Dividing by 4 gives a stable, model-agnostic estimate that is wrong by a consistent factor. Since this skill measures *trends* (is my loop getting more or less expensive?), a stable-biased estimator is sufficient. It is NOT accurate enough for billing, and the skill never claims to be.

Computed with `awk` — no python, no tiktoken, no external tokenizer binary:
```
tokens=$(awk -v c="$char_count" 'BEGIN { print int((c + 3) / 4) }')
```

`char_count` is `wc -c` of the measured file or text. Bytes, not graphemes. This is documented here so downstream readers of token-log.tsv can reproduce the math byte-for-byte.

## TSV Schema
`.godmode/token-log.tsv` is append-only. Header written on first create:
```
timestamp	session_id	round	skill	input_tokens	output_tokens	total_tokens	terse_on	rtk_detected	cumulative_tokens
```

Column meanings:
- `timestamp` — ISO 8601, UTC, second precision.
- `session_id` — matches session-state.json.
- `round` — integer, 1-indexed, monotonic within a session.
- `skill` — name of the driving skill for this round (e.g. `optimize`, `refactor`).
- `input_tokens` — approximate tokens read as context during the round.
- `output_tokens` — approximate tokens emitted by the round.
- `total_tokens` — `input_tokens + output_tokens`.
- `terse_on` — 0 or 1. Useful for comparing terse vs. non-terse sessions.
- `rtk_detected` — 0 or 1. Useful for comparing environments that have rtk installed (input-side compression) vs. those that do not.
- `cumulative_tokens` — running total for this `session_id` including the current round.

Never rewrite history. Never insert. One row per `(session_id, round)` pair. If a row already exists for that pair, SKIP — do not double-log.

## Output Format
At session end, emit a terse summary line (respects GODMODE_TERSE):

Terse:
```
Tokens: session={id} rounds={N} total={T} top={skill}({Ttop}) Δ={±pct}% vs last
```

Normal:
```
Tokens: session {id} completed {N} rounds, total {T} tokens.
Top skill: {skill} at {Ttop} tokens. Delta vs. last session for same skill: {±pct}%.
```

With `--verbose`, also print per-skill breakdown and top-3 expensive rounds:
```
Per-skill breakdown:
  optimize    4 rounds   12800 tok
  debug       2 rounds    3400 tok

Top 3 expensive rounds:
  R7 optimize  4200 tok   (1900 in / 2300 out)
  R3 optimize  3800 tok   (1700 in / 2100 out)
  R5 debug     2100 tok   ( 900 in / 1200 out)
```

Delta vs. last session is computed by scanning token-log.tsv backwards for the previous `session_id` whose top-skill matches, comparing `total` tokens, and printing signed percent.

## Success Criterion
One shell command must answer "is my session's total token consumption going up or down over time?":

```bash
awk -F'\t' 'NR>1 { sum[$2]+=$7; t[$2]=$1 } END {
  for (s in sum) print t[s], s, sum[s]
}' .godmode/token-log.tsv | sort
```

This prints every session chronologically with its total. Piping to `awk 'NR>1 { printf "%s %d delta=%+d\n", $2, $3, $3 - prev } { prev=$3 }'` yields round-over-round deltas. If the last few deltas trend negative, the loop is getting cheaper (terse mode working, rtk helping, prompts tightening). If they trend positive, investigate.

## Hard Rules
1. READ-ONLY to the codebase. The only files this skill may write are `.godmode/token-log.tsv`, `.godmode/token-log.tsv.*.gz`, `.godmode/last-round-emit.txt`, and the session-end summary it prints to stdout. Touching any source file = abort + fail loud.
2. Append-only. Never rewrite or edit existing rows. Rotation is the only way to shrink the active log, and it preserves history as a gzip.
3. Never block the loop. If measurement fails (disk full, permission denied, racing write), emit a warning to stderr and skip the append for that round. The loop must proceed.
4. Never depend on model-specific tokenizers. The char/4 heuristic is the contract. If a future version adds a more accurate estimator, it MUST be additive — old rows stay readable under the documented rule.
5. No real-time streaming. This is per-round append, not a live meter. One row per round, at the DECIDE/LOG boundary, no sooner.
6. Respect `GODMODE_TOKENS=0` unconditionally. Opt-out wins over every other flag, including `--verbose`.
7. Persists across sessions. The file lives in `.godmode/`, which is committed with the rest of godmode state. Never gitignore token-log.tsv.
8. No external deps beyond `awk`, `wc`, `gzip`, `date`, and standard Unix utilities. No python, no jq, no node, no tiktoken.

## Keep / Discard Discipline
This skill does not keep or discard anything — it only observes. Rounds driven by other skills may themselves be kept or discarded per the Universal Protocol; the token row is logged either way, with the driving skill's final keep/discard status inferred from `results.tsv` (not re-measured here). Observing a discarded round is still valuable signal: expensive discards point to skills that burn context without moving the metric.

## Stop Conditions
- `session_ended` — the driving skill hit target_reached, budget_exhausted, diminishing_returns, or stuck. Emit summary, flush any pending row, exit.
- `opted_out` — `GODMODE_TOKENS=0`. Exit silently after the first check.
- `rotation_failed` — gzip returned non-zero or disk full. Emit stderr warning, continue without rotating, do NOT lose the active log.

On any stop: the last row written is authoritative; the summary reflects exactly what is in token-log.tsv, never more.
