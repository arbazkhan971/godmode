# Godmode 2.0: One Loop, Every Harness

> Godmode 2.0 extracts the keep/revert loop from its Claude Code origins
> into a harness-neutral core: one skill corpus, one dispatch contract,
> one installer per platform.

---

## Why harness lock was a ceiling

Godmode 1.x ran, but its center of gravity sat in Claude Code specifics.
Skill bodies referenced `commands/` slash commands, `agents/` definitions,
and entry files (`AGENTS.md`, `GEMINI.md`, `.cursorrules`) as if every
platform had them. Porting meant hand-editing dozens of instruction files,
and each port drifted.

2.0 runs a universal-core pass over the corpus: skill bodies are now
harness-neutral, describing behavior instead of one harness's plumbing.
The rule is enforced rather than aspirational --
`tests/validate-structure.sh` fails the harness-specific "claude"
wording found under `skills/`, with a single allowlisted
exception justified as a functional filename reference. A harness detail
that slips back into a skill now breaks the check, not a user's session.

---

## The universal core

Three pieces make the corpus portable.

**The principles prelude.** Every adapter entry file imports
`skills/principles/SKILL.md` -- the authoring-discipline layer (Think
Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution)
-- so the same rules load before the first edit on any platform.

**Progressive Disclosure.** Each skill exposes a Tier 1 block: frontmatter
plus an `## Activate When` section, capped near 25 lines. Routing reads
Tier 1 only -- a documented routing cost of ~2,700 lines across all 135
skills versus ~27,000 for full-read routing, the ~90% routing-context
reduction claimed in the design docs. Tier 2 loads on activation; Tier 3
loads only when the loop hits a documented edge case.

**A typed dispatch contract.** Orchestrator-to-agent handoffs go through
`DispatchContext` with required fields (`task_id`, `agent_role`, `skill`,
`scope.files`, `budget.rounds`, `budget.timeout_ms`). A missing required
field is a hard error: the agent emits `BLOCKED: invalid_dispatch` and
stops. Nothing silently defaults.

Underneath sits the adapter contract: every adapter ships an `install.sh`
and a `verify.sh`, and platforms without native parallel agents follow a
documented sequential-degradation path -- the same seven built-in
subagents run one at a time, identical results at lower throughput.

---

## The adapter inventory

| Harness | Install | Integration |
| --- | --- | --- |
| Claude Code | `.claude-plugin/` plugin | native agents + worktrees |
| pi | skills into `~/.pi/agent/skills/godmode/` | skills only, no symlinks |
| omp | pi installer + `PREFIX` | dir undocumented; candidates printed |
| Codex | `.codex/` + `AGENTS.md` | sequential execution |
| OpenCode | plugin + `AGENTS.md` | sequential execution |
| Gemini | `GEMINI.md` + `.godmode/` | sequential execution |
| Cursor | `.cursorrules` + `.godmode/` | background agents, file-scoped |
| Amp | none yet | adapter pending |

Every install is idempotent, and each adapter-backed install gets a
one-command smoke test through its `verify.sh` (Claude Code verifies via
the plugin manifest).

---

## goal-bridge: machine-checkable done

Harness goal modes need a definition of done that is not prose. The
`goal-bridge` skill requires a four-field contract before any work
starts:

```text
metric:    one shell command; the goal is met iff it exits 0
threshold: the numeric or boolean bound the metric must satisfy
evidence:  file path where metric output is appended every round
rollback:  the exact trigger that reverts the work
```

That same block is the mandatory final output of the `verify` and `ship`
skills, so every verification ends with the command that proves it. The
skill's own hard rule -- never declare done without exit 0 -- gives a
harness evaluator something it can consume mechanically instead of a
summary it has to trust.

---

## Multi-model routing

Every dispatch names a role. 2.0 lets those roles map to different
models, and the zero-config default is a complete contract on its own:
with no config, every role inherits the session model, and tiering is
opt-in.

Resolution is one rule per role:

`GODMODE_MODEL_<ROLE>` env -> `godmode.models.json` roles -> session model.

An env override is the uppercased role name:

```bash
GODMODE_MODEL_REVIEWER=anthropic/claude-opus-4
```

Durable mappings live in `godmode.models.json` at the repo root or
`~/.config/godmode/models.json` (per-role merge: the repo file wins per key,
roles set only in the user file still apply), keyed by open-ended role:

```json
{"roles": {"optimizer": "zai/glm-5.3", "builder": "openai/gpt-5.2"}}
```

Illustrative only: in a 20-round optimize loop, routing builder and
optimizer rounds to a fast executor model while reviews run on a strong
model shifts spend toward the rounds that benefit -- no benchmark backs
a specific number here. And to be clear about what 2.x does not do:
no daemon, no proxy, no runtime binary. The routing ships as
orchestrator prose in the installed skills plus an optional validator
gate; the orchestrator resolves each role at dispatch time and passes
per-child model parameters.

The routing table is inspectable before a run: `bash adapters/pi/models.sh
doctor` prints role -> model -> source for every role.

---

## What 2.0 does not do

No daemon. No hosted service. No telemetry. Godmode 2.0 is a set of
instruction files, validation scripts, and installers that you run
yourself.

Coverage is incomplete, on the record: omp's exact skill directory is
still undocumented upstream, so installs there rely on the `PREFIX`
override; the Amp adapter has not been written; and the sequential path
trades throughput for fidelity on platforms without parallel agents.

The loop is unchanged from 1.0: measure, keep, discard. What changed is
that the loop no longer assumes who is running it.
