<!-- DRAFT - human fires this post; do not post automatically -->

# Show HN draft: Godmode

## Title

Two candidates, both within the 80-character limit. Post exactly one; do not merge them.

1. `Show HN: Godmode - discipline layer that makes AI coding agents prove their work` (80 chars)
2. `Show HN: Godmode - 135 skills, 7 subagents, one loop: agents prove their work` (77 chars)

## URL

`https://github.com/arbazkhan971/godmode`

Post the repo root as the Show HN link. Do not substitute the release page or a blog post; the repo is the artifact under discussion.

## First comment

The problem: coding agents claim completion and hand you a summary you have to trust. Godmode is a discipline layer - an MIT-licensed set of instruction files and installers you run yourself, no daemon, no telemetry - that puts the agent in a loop it cannot skip: measure -> modify -> verify -> keep or revert.

Each goal is bound to a shell command before work starts. Every change is one atomic commit, then the command and a guard (tests, lint, build) run again. Improved: the change is kept. Worse or broken: it is reverted automatically and the failure is classified for the next attempt.

The goal-bridge skill makes done machine-checkable: the metric is one shell command that must exit zero, with evidence and rollback declared up front.

The same 135 skills and 7 subagents run on Claude Code, Codex, Cursor, Gemini CLI, OpenCode, pi, and omp.

Honest weakest point: the demo traces in the README are representative illustrations, not captured benchmarks. Real run recordings are tracked in issue #9.

## Anticipated questions

**Q: How is this different from a linter or CI?**

CI reports failure after you push; it does not stop the agent mid-loop. Godmode acts inside the loop: the change is committed, the metric and guards run, and a regression is reverted before the session moves on. It also answers questions a linter cannot, like whether a change actually made an endpoint faster, because the goal is bound to a command that measures exactly that.

**Q: Does it work outside Claude Code?**

Yes. The same loop runs on Codex, Cursor, Gemini CLI, OpenCode, pi, and omp. Subagents run in parallel where the harness supports it and degrade to sequential elsewhere. Amp has no adapter yet; the docs say so plainly instead of glossing it.

**Q: What does keep/revert actually measure?**

Whatever you bind to the goal: a shell command with an exit status and, when the output is numeric, a threshold you set. The agent has to show before-and-after output; improved means measured improvement, not a claim. If the metric does not improve or a guard fails, the commit is reset.

## Author conduct

The author answers comments in the thread; the prepared answers above are starting points.
