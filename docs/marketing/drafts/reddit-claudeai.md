<!-- DRAFT - human fires this post; do not post automatically -->

# r/ClaudeAI post draft: Godmode

## Title

Two candidates. Post exactly one; do not merge them.

1. `My Claude Code agent kept saying 'done' with nothing behind it, so I built a discipline layer` (93 chars) - problem-first, names the tool only as the solution at the end.
2. `My Claude Code agent writes code; I added a layer that makes it prove its work` (78 chars) - shorter, same problem-first framing.

## Flair note

Human action: open the subreddit's current flair list and pick the closest match before submitting. Do not assume any specific flair name offered here still exists; flair sets change. A resource or project-showcase style flair is the likely fit if one exists.

## Body

Disclosure: I am the author - this is built by arbazkhan971. I will be in the comments answering questions, including critical ones.

**Claude Code first.** It installs as a plugin: `claude plugin install godmode`. Then `/godmode optimize my API` and walk away - it measures, iterates, keeps improvements, reverts failures, and stops when done.

**What it is.** Godmode is a discipline layer for AI coding agents: an MIT-licensed set of instruction files and installers you run yourself - no daemon, no hosted service, no telemetry. It ships 135 skills and 7 subagents, and it wraps the agent you already use in a loop it cannot skip.

**The loop.** Measure -> modify -> verify -> keep or revert. Before any code is touched, the agent binds your goal to one shell command; the goal is met only when that command exits zero. Each iteration then makes one change, commits it, and reruns the command plus guards (tests, lint, build).

**A concrete run.** I ask the agent to make a slow endpoint faster. It reads the current state, picks the change the evidence supports - say, an index on a hot query - commits it, and reruns the metric command. Metric improved and tests green: the commit stays. Metric flat or worse, or a guard red: the commit is reverted automatically, and the failure is written to a memory file the agent consults before its next attempt. The final summary contains commands and their output, not adjectives.

**Where it runs.** Claude Code, Codex, Cursor, Gemini CLI, OpenCode, pi, and omp. Same skills everywhere; subagents run in parallel where the harness supports them and sequentially elsewhere. The Amp adapter is not written yet, and the docs say so.

**What it will NOT do.** It is not autocomplete. It is not a model - it drives whatever agent you already run. It does not replace your tests; it forces the agent to prove its work against your tests and a metric you choose. If you bind a bad metric, it will optimize the wrong thing, honestly.

One honest caveat: the demo traces in the README are representative illustrations, not captured benchmarks; real run recordings are being tracked in the repo's issue #9.

Links:

- Repo: <https://github.com/arbazkhan971/godmode>
- v2.0.0 release: <https://github.com/arbazkhan971/godmode/releases/tag/v2.0.0>
- How 2.0 works, in detail: <https://github.com/arbazkhan971/godmode/blob/master/docs/blog/godmode-2.0-universal.md>

## Rules check

- Authorship disclosed in the first line of the body, not buried; the author stays in the comments for the life of the thread.
- Links point to source under an open license; no paywall, no signup, no tracking, nothing to buy.
- No engagement asks of any kind appear anywhere in the post - verified line by line against the project's own banned-phrase list.
- Limitations are stated inside the post itself (Amp adapter missing, bad metrics get optimized honestly, README traces are illustrative).
- One post to this community only. If it lands poorly, it is not reposted or resubmitted in another form.
- Poster verifies their own account's self-promotion ratio (9:1) against the current reddit content policy and the subreddit sidebar immediately before submitting, since those change.
