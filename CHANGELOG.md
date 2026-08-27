# Changelog

All notable changes to Godmode are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Real demo captures: three vhs tapes under `demo/` recording live pi sessions (zai/glm-5.3) — godmode skill routing, the optimize keep/revert loop (real metric, real KEEP, real `git reset --hard` revert), and a goal-bridge completion contract (red test → green, evidence file); rendered GIFs embedded in the README "See It In Action" section replacing the former illustrative-traces TODO, with text transcript fallbacks in `demo/transcripts/` and re-renderable via `bash demo/render.sh`.
- Amp adapter: `adapters/amp/` (`install.sh` + `verify.sh` + adapter docs) wires skills into Amp's `.agents/skills/` project skills directory (symlinked for live sync, with a `cp -rL` copy escape hatch) and copies `AGENTS.md` into the project root without clobbering a user-authored file (writes an `AGENTS.godmode.md` sidecar instead). Skills-only integration: godmode's 7 subagent roles are not injected, dispatch runs sequentially by prompting Amp's own subagents.
- Multi-model role routing: optional `godmode.models.json` (project root, merged per-key over `~/.config/godmode/models.json`) plus `GODMODE_MODEL_<ROLE>` env overrides, with a valid zero-config default where every role inherits the session model. Ships the pi reference resolver (`adapters/pi/models.sh` `resolve`/`doctor`/`selftest`), orchestrator Step 3c role resolution at dispatch time, the `setup` Step 6b routing wizard, the `verify` doctor check, and validator Check 7.

### Planned

- Plugin marketplace listing
- VSCode extension for Godmode status display
- Web dashboard for optimization and fix logs
- Additional language-specific skill variants
- Community skill contributions

## [2.0.0] - 2026-08-27

### Added

#### Universal core

- Harness-neutral skill corpus: platform-specific wording removed from skill bodies; automated gate in `tests/validate-structure.sh` fails if `skills/**` contains the harness-specific "claude" wording (single justified allowlist entry).
- Authoring-discipline prelude (`skills/principles`) and pre-commit discard audit reachable from every adapter.
- Four-layer token stack: Progressive Disclosure routing (~90% routing-context reduction), stdio command patterns, terse output mode, token observability.
- DispatchContext validation for all 7 subagents; named coordination patterns; research auto-dispatch.

#### pi / omp adapter

- `adapters/pi/`: `install.sh` + `verify.sh`; installs all skills into `$PREFIX/godmode/`; `PREFIX` override serves omp-compatible forks (omp exact dir undocumented — installer prints candidate paths).

#### goal-bridge skill

- `skills/goal-bridge/`: machine-checkable completion contracts (metric command, threshold, evidence path, rollback trigger; exit-0 semantics); `verify` and `ship` emit the contract block as final output.

#### Skills

- 135 skills across 13 domains (up from 16 in 1.0.0), including `goal-bridge` and the Discipline & Context skills.

#### README 2.0

- One-sentence intro; per-harness support matrix (8 harnesses); demo traces labeled as representative with a TODO for real captures.

### Fixed

- `adapters/pi/install.sh` rejects root-equivalent `PREFIX` values (`/`, `//`, `/.`) instead of installing/deleting under the filesystem root; an empty `PREFIX` falls back to the default skills directory.
- `adapters/shared/verify-common.sh` JSON validation no longer interpolates filenames into `python3 -c`; identical pass/fail semantics.
- `skills/tokens/SKILL.md` recommends gitignoring `.godmode/last-round-emit.txt` (rewritten scratch cache; append-only `token-log.tsv` stays committed).
- Adapter verify scripts and `adapters/shared/verify-common.sh` carried a hard-coded expected skill count of 126 and failed against the current 135-skill corpus; expected count corrected to 135.

## [1.0.0] - 2024-01-15

### Added

#### Skills (16 total)

- **godmode** — Orchestrator skill that auto-detects project phase and routes to the right sub-skill
- **think** — Collaborative brainstorming with 2-3 approach generation and spec writing
- **predict** — Multi-persona expert consensus with 5 domain-specific evaluators
- **scenario** — Edge case exploration across 12 dimensions (happy path to data lifecycle)
- **plan** — Task decomposition into 2-5 minute atomic tasks with code sketches
- **build** — TDD execution (RED-GREEN-REFACTOR) with parallel agent dispatch
- **test** — TDD enforcement with test quality checklist and coverage tracking
- **review** — 2-stage code review: automated checks + 7-dimension agent review
- **optimize** — Autonomous iteration loop with mechanical verification and git-as-memory
- **debug** — Scientific debugging with 7 investigation techniques
- **fix** — Autonomous error remediation: one fix per iteration until zero errors
- **secure** — STRIDE + OWASP Top 10 + 4 red-team personas security audit
- **ship** — 8-phase shipping workflow with dry-run and post-deploy monitoring
- **finish** — Branch finalization (merge, PR, keep, or discard)
- **setup** — Configuration wizard with auto-detection and validation
- **verify** — Evidence gate enforcing "prove it before claiming it"

#### Commands (9 total)

- `/godmode` — Main orchestrator command
- `/godmode:think` — Brainstorm subcommand
- `/godmode:plan` — Plan subcommand
- `/godmode:build` — Build subcommand
- `/godmode:optimize` — Optimize subcommand
- `/godmode:debug` — Debug subcommand
- `/godmode:fix` — Fix subcommand
- `/godmode:secure` — Secure subcommand
- `/godmode:ship` — Ship subcommand

#### Agents (2 total)

- **code-reviewer** — 7-dimension code review agent with scored findings
- **spec-reviewer** — 5-dimension specification review agent

#### Infrastructure

- Session-start hook with auto-detection for 7 languages
- `.godmode/config.yaml` configuration system
- TSV logging for optimize results, fix log, and ship log
- Plugin marketplace metadata

#### Documentation

- Getting started guide with end-to-end walkthrough
- 3 example workflows (API feature, bug fix, optimization)
- Domain guide (backend, frontend, ML, content, DevOps)
- Skill chaining guide with 8 common patterns
- CI/CD integration guide (GitHub Actions, GitLab CI)
- Architecture overview
- Contributing guide

#### Reference Documents

- Autonomous loop protocol (full specification)
- Core principles (7 non-negotiable rules)
- Results logging format (TSV schema)
- Security workflow (STRIDE checklist, red-team playbooks)
- Debug workflow (7 techniques with detailed steps)
- Fix workflow (prioritization, cascade detection)
- Ship workflow (checklists, rollback protocol)
