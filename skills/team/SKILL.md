---
name: team
description: |
  Invoke a named bundle of existing godmode skills as a single unit.
  A team bundle is a YAML file that lists skills + a coordination pattern;
  this skill resolves the bundle, validates it, and dispatches the skills
  in pattern order. Ships the primitive only — no pre-made teams.
  Triggers on: /godmode:team <name>.
---

## Activate When
- `/godmode:team <name>` — load `.godmode/teams/<name>.yaml` and dispatch
- `/godmode:team` without a name — list bundles found in `.godmode/teams/`
- Natural language "run the <name> team" or "use the <name> bundle"

A team bundle is the INVOCATION layer. `docs/coordination-patterns.md` is the
VOCABULARY layer. Individual skills under `skills/` are the WORK layer. This
skill is only glue — it never defines new skill logic inline.

## Bundle Format
Each team lives at `.godmode/teams/<name>.yaml`. Fields:

```yaml
name: api-backend                         # team name, matches filename
description: |                            # one paragraph, rendered on list
  Stand up a production API: routes,
  auth, rate limiting, and a security pass.
pattern: Pipeline                         # one of the 6 known patterns
skills:                                   # ordered, max 10
  - api
  - auth
  - ratelimit
  - secure
constraints:                              # optional, applied to every skill
  - budget.rounds=5
  - max_agents=3
success_criterion: |                      # shell, exits 0 when team succeeds
  npm test && npm run lint && curl -fsS localhost:3000/health
```

The example above is the reference format — do NOT ship it as a real bundle.
Users author their own. The `.godmode/teams/` directory is created by the
user (or by whatever tool they write to author bundles), not by this skill.

## Pattern Must Be One Of
From `docs/coordination-patterns.md`:
`Pipeline`, `Fan-out/Fan-in`, `Expert Pool`, `Producer-Reviewer`,
`Supervisor`, `Hierarchical Delegation`. Anything else →
`BLOCKED: invalid_pattern`. Never invent a new pattern; if a bundle needs
something not on the list, the bundle is wrong, not the list.

## Workflow

### 1. Resolve Bundle
```bash
test -f .godmode/teams/<name>.yaml || exit 1   # BLOCKED: no_such_team
python3 -c "import yaml; yaml.safe_load(open('.godmode/teams/<name>.yaml'))"
```
Read `name`, `description`, `pattern`, `skills`, optional `constraints`,
`success_criterion`. Fail fast on missing required fields.

### 2. Validate
- `pattern` ∈ the 6 known patterns — else `BLOCKED: invalid_pattern`
- `len(skills) <= 10` — else `BLOCKED: team_too_large`
- Every entry in `skills` resolves to an existing `skills/<skill>/SKILL.md` —
  first miss → `BLOCKED: unknown_skill:<name>`
- `success_criterion` is a non-empty string (shell command, never prose)
- `constraints` entries parse as `key=value`

### 3. Dispatch by Pattern
```
CASE pattern OF
  Pipeline               → run skills sequentially, pipe each
                           skill's output into the next as context
  Fan-out/Fan-in         → dispatch all skills in parallel worktrees,
                           merge in declared order (per build.md rules)
  Expert Pool            → evaluate triggers from skills/godmode/SKILL.md
                           Step 2, run exactly ONE skill from the list
  Producer-Reviewer      → skills[0] generates, skills[1] reviews,
                           remaining skills run only if reviewer accepts
  Supervisor             → skills[0] acts as supervisor and decides
                           which of the remaining skills to run next;
                           loop until supervisor reports DONE
  Hierarchical Delegation→ skills[0] decomposes, each output skill is
                           dispatched with depth+1, max depth = 2
```
Apply `constraints` to every dispatched skill before it runs.

### 4. One Big Autoresearch Loop
Team execution is a single outer loop where each skill is one round:
```
round = 0
FOR skill IN ordered_dispatch_plan:
  round += 1
  result = run_skill(skill, prev_output, constraints)
  LOG .godmode/team-log.tsv
  IF result.status != "DONE":          # Universal Protocol failure
    EMIT "team <name> stopped at skill <skill> round <round>"
    EXIT 1                             # cascade — do not continue
  prev_output = result
EVAL success_criterion                 # whole-team gate
```

### 5. Success Gate
Run `success_criterion` as a shell command. Exit 0 → team DONE. Non-zero →
the team failed even though every skill reported DONE; log
`criterion_failed` and exit 1. No retry at the team layer — the user
decides whether to rerun.

## Example Bundle: api-backend
```yaml
name: api-backend
description: |
  Build a production-ready HTTP API: scaffold routes, wire auth,
  rate-limit the public endpoints, and run a security audit.
pattern: Pipeline
skills:
  - api
  - auth
  - ratelimit
  - secure
constraints:
  - budget.rounds=5
  - max_agents=3
success_criterion: |
  npm test && npm run lint && \
    curl -fsS localhost:3000/health > /dev/null
```
Invocation: `/godmode:team api-backend`. The orchestrator runs `api`, feeds
its output to `auth`, that to `ratelimit`, that to `secure`, then gates on
the shell `success_criterion`. Any skill that emits a Universal Protocol
failure (`STUCK`, `BLOCKED`, etc.) halts the whole team.

## TSV Logging
Append one row per dispatched skill to `.godmode/team-log.tsv`:
```
timestamp	team	pattern	round	skill	status	elapsed_ms	notes
```
At team completion append a summary row with `skill=__team__` and
`status ∈ {DONE, FAILED, criterion_failed}` and total elapsed time.

## Hard Rules
1. Teams COMPOSE existing skills. Never define new skill logic inside a
   bundle. A bundle is pure wiring.
2. Missing skill in `skills:` → `BLOCKED: unknown_skill:<name>`. The
   bundle is invalid — do not partially run it.
3. Unknown or missing pattern → `BLOCKED: invalid_pattern`. Must be one of
   the 6 from `docs/coordination-patterns.md`.
4. Max 10 skills per team. Longer chains are runaway. Split into multiple
   teams and compose them via Pipeline.
5. Cascade on failure: if skill N fails the Universal Protocol, stop and
   log which skill failed. Never skip a failed skill.
6. No new coordination patterns. No registry. No marketplace. No catalog
   of pre-made teams shipped with godmode.
7. `.godmode/teams/` is user-owned. This skill reads from it, never writes
   to it.

## Keep/Discard Discipline
```
KEEP a team run if: every dispatched skill reported DONE
  AND success_criterion exited 0.
DISCARD otherwise: log which skill or criterion failed.
The team layer does not git-reset — individual skills already
follow the Universal Protocol and own their own reverts.
```

## Stop Conditions
```
STOP when FIRST of:
  - target_reached:    every skill DONE and success_criterion passed
  - bundle_invalid:    validation failed before dispatch
  - skill_failed:      one skill cascaded a Universal Protocol failure
  - criterion_failed:  every skill DONE but success_criterion non-zero
```

<!-- tier-3 -->

## Error Recovery
| Failure | Action |
|---|---|
| `BLOCKED: no_such_team` | List `.godmode/teams/*.yaml`, suggest closest name. |
| `BLOCKED: invalid_pattern` | Print the 6 valid patterns. Bundle author fixes. |
| `BLOCKED: unknown_skill:<n>` | List `skills/*/SKILL.md`, suggest closest match. |
| `BLOCKED: team_too_large` | Split the bundle; compose two teams via Pipeline. |
| `skill_failed` at round N | Log skill+round. User decides rerun or edit bundle. |
| `criterion_failed` | Team did not achieve goal. No auto-retry at team layer. |

## Relationship to Other Skills
- `skills/godmode/SKILL.md` — the orchestrator. Routes `/godmode:team` here.
- `docs/coordination-patterns.md` — the vocabulary. Every `pattern` value
  must come from this file.
- `skills/plan/SKILL.md` — declares a pattern in its plan header; a team
  bundle is the same idea at invocation time instead of plan time.
- `skills/build/SKILL.md` — Fan-out dispatch rules used when a team picks
  the Fan-out/Fan-in pattern.
- Individual work skills (`api`, `auth`, `secure`, ...) — the atoms a team
  bundle composes. This skill never replaces them.
