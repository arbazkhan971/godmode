# Changelog

All notable changes to Godmode are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

## [Unreleased]

### Planned
- Plugin marketplace listing
- VSCode extension for Godmode status display
- Web dashboard for optimization and fix logs
- Additional language-specific skill variants
- Community skill contributions
